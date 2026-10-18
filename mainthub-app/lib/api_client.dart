import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  /// Global callback invoked when an authenticated request receives a 401/422,
  /// indicating token expiration, backend redeployment, or session invalidation.
  static void Function()? onSessionExpired;
  static bool _isHandlingExpiry = false;

  static void triggerSessionExpired() {
    if (_isHandlingExpiry) return;
    _isHandlingExpiry = true;
    try {
      onSessionExpired?.call();
    } finally {
      Future.delayed(const Duration(seconds: 3), () {
        _isHandlingExpiry = false;
      });
    }
  }

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl:        AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      contentType:    'application/json',
    ));

    // Attach JWT token to every request automatically
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final statusCode = error.response?.statusCode;
        final path = error.requestOptions.path;
        final isAuthEndpoint = path.contains('/auth/login') ||
            path.contains('/auth/register') ||
            path.contains('/auth/signup') ||
            path.contains('/users/register');

        // If the backend returns 401 (Unauthorized) or 422 (Unprocessable/Invalid token)
        // on a protected endpoint, the session is no longer valid (e.g. backend redeployed).
        if ((statusCode == 401 || statusCode == 422) && !isAuthEndpoint) {
          await _storage.deleteAll();
          triggerSessionExpired();
        }

        handler.next(error);
      },
    ));
  }

  Future<Response> get(String path)                          => _dio.get(path);
  Future<Response<List<int>>> getBytes(String path)          => _dio.get<List<int>>(
    path,
    options: Options(responseType: ResponseType.bytes),
  );
  Future<Response> post(String path, {dynamic data})         => _dio.post(path, data: data);
  Future<Response> put(String path, {dynamic data})          => _dio.put(path, data: data);
  Future<Response> delete(String path)                       => _dio.delete(path);
}

