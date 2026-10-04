import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/machine.dart';
import 'local_notification_service.dart';
import 'machine_service.dart';

/// Pulldown/system notifications for overdue & due-today machines.
/// Runs on login / dashboard open / app resume. No email — device alerts only.
class OverdueAlertService {
  OverdueAlertService._();
  static final OverdueAlertService instance = OverdueAlertService._();

  final _machines = MachineService();
  final _local = LocalNotificationService.instance;

  Future<void> initialize() async {
    await _local.init();
  }

  /// Call after login / when dashboard loads / on pull-to-refresh / app resume.
  Future<void> checkAndNotify({bool force = false}) async {
    await _local.init();
    final allowed = await _local.requestPermission();
    if (!allowed) {
      debugPrint('[OverdueAlert] notification permission not granted');
      return;
    }

    List<Machine> machines;
    try {
      machines = await _machines.getMachines();
    } catch (e) {
      debugPrint('[OverdueAlert] failed to load machines: $e');
      return;
    }

    final active = machines.where((m) => m.status == 'ACTIVE').toList();
    final overdue = active.where((m) => m.isOverdue).toList()
      ..sort((a, b) => a.nextMaintenanceDate.compareTo(b.nextMaintenanceDate));
    final dueToday = active.where((m) => m.isDueToday).toList();

    if (overdue.isEmpty && dueToday.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final fingerprint = _fingerprint(overdue, dueToday);
    final lastDay = prefs.getString('overdue_alert_day');
    final lastFp = prefs.getString('overdue_alert_fp');

    if (!force && lastDay == today && lastFp == fingerprint) {
      return; // already notified for this set today
    }

    if (overdue.isNotEmpty) {
      if (overdue.length == 1) {
        final m = overdue.first;
        await _local.show(
          id: 1000 + m.id,
          title: 'OVERDUE: ${m.name}',
          body:
              '${m.departmentLabel} at ${m.location ?? 'N/A'} was due on ${m.nextMaintenanceDate}.',
        );
      } else {
        final names = overdue.take(5).map((m) => m.name).join(', ');
        final extra = overdue.length > 5 ? ' and ${overdue.length - 5} more' : '';
        await _local.show(
          id: 9001,
          title: '${overdue.length} machines overdue',
          body: '$names$extra need maintenance.',
        );
      }
    }

    if (dueToday.isNotEmpty) {
      if (dueToday.length == 1) {
        final m = dueToday.first;
        await _local.show(
          id: 2000 + m.id,
          title: 'Due today: ${m.name}',
          body:
              '${m.departmentLabel} at ${m.location ?? 'N/A'} is due for maintenance today.',
        );
      } else {
        final names = dueToday.take(5).map((m) => m.name).join(', ');
        final extra =
            dueToday.length > 5 ? ' and ${dueToday.length - 5} more' : '';
        await _local.show(
          id: 9002,
          title: '${dueToday.length} machines due today',
          body: '$names$extra.',
        );
      }
    }

    await prefs.setString('overdue_alert_day', today);
    await prefs.setString('overdue_alert_fp', fingerprint);
  }

  Future<void> stopPeriodicChecks() async {
    // Kept for logout call-sites; no background scheduler currently.
  }

  String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  String _fingerprint(List<Machine> overdue, List<Machine> dueToday) {
    final o = overdue.map((m) => 'o${m.id}').join(',');
    final d = dueToday.map((m) => 'd${m.id}').join(',');
    return '$o|$d';
  }
}
