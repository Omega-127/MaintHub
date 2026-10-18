import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final _client  = ApiClient();
  final _storage = const FlutterSecureStorage();

  // Save session to secure storage
  Future<void> saveUserSession(String token, User user) async {
    await _storage.write(key: 'access_token', value: token);
    await _storage.write(key: 'user_role',    value: user.role);
    if (user.department != null && user.department!.isNotEmpty) {
      await _storage.write(key: 'user_department', value: user.department!);
    } else {
      await _storage.delete(key: 'user_department');
    }
    await _storage.write(key: 'user_id', value: user.id.toString());
    await _storage.write(key: 'user_profile', value: jsonEncode(user.toJson()));
  }

  // Retrieve cached user profile from secure storage
  Future<User?> getCachedUser() async {
    try {
      final profileStr = await _storage.read(key: 'user_profile');
      if (profileStr != null && profileStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(profileStr);
        return User.fromJson(data);
      }
      final role = await _storage.read(key: 'user_role');
      if (role != null) {
        final dept = await _storage.read(key: 'user_department');
        final idStr = await _storage.read(key: 'user_id');
        return User(
          id: int.tryParse(idStr ?? '0') ?? 0,
          fullName: 'User',
          email: '',
          role: role,
          department: dept,
        );
      }
    } catch (_) {}
    return null;
  }

  // Login → returns User on success, throws on failure
  Future<User> login(String email, String password) async {
    final response = await _client.post('/auth/login', data: {
      'email':    email,
      'password': password,
    });

    final token = response.data['access_token'];
    final user  = User.fromJson(response.data['user']);

    // Store token and user securely
    await saveUserSession(token, user);
    return user;
  }

  // Sign up → register user and store token
  Future<User> signUp({
    required String fullName,
    required String email,
    required String password,
    String  role       = 'TECHNICIAN',
    String? department,           // BLOWROOM | COMBER | RING_FRAME | SPEED_FRAME | WINDING | BUFFING | null (for ADMIN)
  }) async {
    final payload = <String, dynamic>{
      'full_name': fullName,
      'name':      fullName,
      'email':     email,
      'password':  password,
      'role':      role,
    };
    if (department != null) {
      payload['department'] = department;
    }

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
      await saveUserSession(token, user);
      return user;
    } else {
      return await login(email, password);
    }
  }

  // Logout — clear stored token and profile
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  // Check if token exists (used on app start)
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Get current user info from backend or fallback to cached profile on network errors
  Future<User?> getCurrentUser() async {
    try {
      final response = await _client.get('/auth/me');
      final user = User.fromJson(response.data);
      final token = await getToken();
      if (token != null) {
        await saveUserSession(token, user);
      }
      return user;
    } on DioException catch (e) {
      // 401/422 indicates invalid token or backend redeployment
      if (e.response?.statusCode == 401 || e.response?.statusCode == 422) {
        await logout();
        return null;
      }
      // If network error, timeout, or backend sleeping/cold starting, return cached profile
      return await getCachedUser();
    } catch (_) {
      return await getCachedUser();
    }
  }
}