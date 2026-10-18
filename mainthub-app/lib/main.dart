import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/machine_provider.dart';
import 'screens/splash_screen.dart';
import 'services/overdue_alert_service.dart';

import 'services/notification_navigator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OverdueAlertService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MachineProvider()),
      ],
      child: MaterialApp(
        navigatorKey: NotificationNavigator.navigatorKey,
        title: 'MainHub',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
