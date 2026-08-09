import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  // Base backend server URL.
  // Note for testing:
  // - Physical Device on Wi-Fi: use PC local IP (e.g. http://192.168.1.5:5000/api)
  // - Android Emulator: use http://10.0.2.2:5000/api
  // - Web / iOS Simulator: use http://localhost:5000/api
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    return 'http://192.168.1.5:5000/api';
  }

  static const String appName = 'MainHub';
}
