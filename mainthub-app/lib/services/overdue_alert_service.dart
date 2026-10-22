import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/machine.dart';
import 'local_notification_service.dart';
import 'machine_service.dart';

/// Manages system notifications for maintenance alerts.
/// Schedules recurring daily notifications at 7:00 AM and 1:00 PM (13:00).
class OverdueAlertService {
  OverdueAlertService._();
  static final OverdueAlertService instance = OverdueAlertService._();

  final _machines = MachineService();
  final _local = LocalNotificationService.instance;

  static const int morningNotificationId = 700;
  static const int afternoonNotificationId = 1300;

  Future<void> initialize() async {
    await _local.init();
  }

  /// Configures and updates scheduled daily notifications (7:00 AM & 1:00 PM).
  /// If [force] is true, an immediate alert is also displayed for testing.
  Future<void> checkAndNotify({bool force = false}) async {
    await _local.init();
    final allowed = await _local.requestPermission();
    if (!allowed) {
      debugPrint('[OverdueAlert] Notification permission not granted');
      return;
    }

    List<Machine> machines = [];
    bool fetchSuccess = false;
    try {
      machines = await _machines.getMachines();
      fetchSuccess = true;
    } catch (e) {
      debugPrint('[OverdueAlert] Failed to load machines for alert schedule: $e');
    }

    final active = machines.where((m) => m.status == 'ACTIVE').toList();
    final overdue = active.where((m) => m.isOverdue).toList()
      ..sort((a, b) => a.nextMaintenanceDate.compareTo(b.nextMaintenanceDate));
    final dueToday = active.where((m) => m.isDueToday).toList();
    final int totalNeedingService = overdue.length + dueToday.length;

    String morningTitle;
    String morningBody;
    String morningPayload;

    String afternoonTitle;
    String afternoonBody;
    String afternoonPayload;

    if (fetchSuccess && totalNeedingService > 0) {
      final List<String> topNames = [
        ...overdue.map((m) => m.name),
        ...dueToday.map((m) => m.name),
      ].take(4).toList();
      final String namesStr = topNames.join(', ');
      final String extraStr = totalNeedingService > topNames.length
          ? ' +${totalNeedingService - topNames.length} more'
          : '';

      morningTitle = overdue.isNotEmpty
          ? '⚠️ 7:00 AM Morning Alert: $totalNeedingService Machine(s) Due'
          : '🔔 7:00 AM Morning Check: $totalNeedingService Machine(s) Due Today';
      morningBody = overdue.isNotEmpty
          ? '${overdue.length} overdue, ${dueToday.length} due today ($namesStr$extraStr). Tap to service.'
          : '$namesStr$extraStr scheduled for maintenance today. Tap to inspect.';
      morningPayload = overdue.isNotEmpty ? 'overdue' : 'due_today';

      afternoonTitle =
          '⚠️ 1:00 PM Afternoon Review: $totalNeedingService Pending';
      afternoonBody =
          'Afternoon shift review: $namesStr$extraStr require maintenance. Tap to update.';
      afternoonPayload = overdue.isNotEmpty ? 'overdue' : 'due_today';
    } else if (fetchSuccess) {
      morningTitle = '🔔 7:00 AM Morning Maintenance Inspection';
      morningBody =
          'All machinery is currently up to date. Tap to inspect today\'s plant schedule.';
      morningPayload = 'routine_inspection';

      afternoonTitle = '🔔 1:00 PM Afternoon Shift Review';
      afternoonBody =
          'Shift handover review: All machinery operational. Tap to verify service logs.';
      afternoonPayload = 'routine_inspection';
    } else {
      // Fallback copy if offline / network error
      morningTitle = '🔔 7:00 AM Morning Maintenance Check';
      morningBody = 'Review morning shift machinery inspection and schedules.';
      morningPayload = 'overdue';

      afternoonTitle = '🔔 1:00 PM Afternoon Maintenance Review';
      afternoonBody =
          'Review afternoon shift machine status and service logs.';
      afternoonPayload = 'overdue';
    }

    // Schedule 7:00 AM Daily Morning Notification
    await _local.scheduleDaily(
      id: morningNotificationId,
      hour: 7,
      minute: 0,
      title: morningTitle,
      body: morningBody,
      payload: morningPayload,
    );

    // Schedule 1:00 PM (13:00) Daily Afternoon Notification
    await _local.scheduleDaily(
      id: afternoonNotificationId,
      hour: 13,
      minute: 0,
      title: afternoonTitle,
      body: afternoonBody,
      payload: afternoonPayload,
    );

    // Save timestamp of last scheduled update
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_alerts_scheduled_timestamp',
        DateTime.now().millisecondsSinceEpoch);

    // Immediate notification is ONLY sent if explicitly forced (e.g., test trigger)
    if (force && totalNeedingService > 0) {
      if (overdue.isNotEmpty) {
        final m = overdue.first;
        await _local.show(
          id: 1000 + m.id,
          title: 'OVERDUE: ${m.name}',
          body:
              '${m.departmentLabel} at ${m.location ?? 'N/A'} was due on ${m.nextMaintenanceDate}.',
          payload: 'overdue',
        );
      } else if (dueToday.isNotEmpty) {
        final m = dueToday.first;
        await _local.show(
          id: 2000 + m.id,
          title: 'Due today: ${m.name}',
          body:
              '${m.departmentLabel} at ${m.location ?? 'N/A'} is due for maintenance today.',
          payload: 'due_today',
        );
      }
    }
  }

  /// Cancels all scheduled daily notifications (e.g. on user logout).
  Future<void> stopPeriodicChecks() async {
    await _local.cancel(morningNotificationId);
    await _local.cancel(afternoonNotificationId);
    debugPrint('[OverdueAlert] Cancelled daily shift notification schedules');
  }
}
