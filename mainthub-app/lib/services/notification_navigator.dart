import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/maintanance/pending_screen.dart';
import '../screens/maintanance/due_soon_screen.dart';

class NotificationNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static String? _pendingPayload;

  static void setPendingPayload(String? payload) {
    _pendingPayload = payload;
  }

  /// Navigate to the matching screen based on payload
  static void navigateFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;

    final context = navigatorKey.currentContext;
    if (context == null) {
      // Store to navigate once context is ready
      _pendingPayload = payload;
      return;
    }

    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      _pendingPayload = payload;
      return;
    }

    final userDept = auth.user?.isAdmin == true ? null : auth.user?.department;

    if (payload == 'overdue') {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => PendingMaintenanceScreen(department: userDept),
        ),
      );
    } else if (payload == 'due_today' || payload == 'due_soon') {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => DueSoonScreen(department: userDept),
        ),
      );
    }
  }

  /// Consumed when the user lands on the dashboard
  static void checkAndConsumePendingPayload() {
    if (_pendingPayload != null) {
      final payload = _pendingPayload;
      _pendingPayload = null;
      Future.microtask(() => navigateFromPayload(payload));
    }
  }
}
