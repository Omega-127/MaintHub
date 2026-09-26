class AppConfig {
  // Must include /api — backend routes are /api/auth, /api/machines, etc.
  // Free Render services cold-start slowly; keep client timeouts high.
  static const String baseUrl = 'https://mainthub-backend.onrender.com/api';

  static const String appName = 'MainHub';
}
