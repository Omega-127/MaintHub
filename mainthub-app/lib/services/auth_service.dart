import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final _client  = ApiClient();
  final _storage = const FlutterSecureStorage();

  // Login → returns User on success, throws on failure
  Future<User> login(String email, String password) async {
    final response = await _client.post('/auth/login', data: {
      'email':    email,
      'password': password,
    });

    final token = response.data['access_token'];
    final user  = User.fromJson(response.data['user']);

    // Store token securely
    await _storage.write(key: 'access_token', value: token);
    await _storage.write(key: 'user_role',    value: user.role);

    return user;
  }

  // Sign up → register user and store token
  Future<User> signUp({
    required String fullName,
    required String email,
    required String password,
    String role = 'TECHNICIAN',
  }) async {
    final payload = {
      'full_name': fullName,
      'name':      fullName,
      'email':     email,
      'password':  password,
      'role':      role,
    };

    Response response;
    try {
      response = await _client.post('/auth/register', data: payload);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        try {
          response = await _client.post('/auth/signup', data: payload);
        } on DioException catch (_) {
          response = await _client.post('/users/register', data: payload);
        }
      } else {
        rethrow;
      }
    }

    if (response.data != null &&
        response.data is Map &&
        response.data['access_token'] != null) {
      final token = response.data['access_token'];
      final user  = User.fromJson(response.data['user'] ?? response.data);
      await _storage.write(key: 'access_token', value: token);
      await _storage.write(key: 'user_role',    value: user.role);
      return user;
    } else {
      return await login(email, password);
    }
  }

  // Logout — clear stored token
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  // Check if token exists (used on app start)
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }

  // Get current user info from backend
  Future<User?> getCurrentUser() async {
    try {
      final response = await _client.get('/auth/me');
      return User.fromJson(response.data);
    } catch (_) {
      return null;
    }
  }
}