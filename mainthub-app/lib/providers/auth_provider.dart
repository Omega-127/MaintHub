import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../api_client.dart';
import '../config/theme.dart';
import '../screens/machines/login_screen.dart';
import '../services/notification_navigator.dart';

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();

  User?  _user;
  bool   _isLoading = false;
  String _error     = '';

  User?  get user       => _user;
  bool   get isLoading  => _isLoading;
  String get error      => _error;
  bool   get isLoggedIn => _user != null;

  AuthProvider() {
    // Automatically handle 401/422 when backend redeploys or token is invalidated
    ApiClient.onSessionExpired = handleSessionExpired;
  }

  void handleSessionExpired() {
    _user = null;
    notifyListeners();

    final nav = NotificationNavigator.navigatorKey.currentState;
    final context = NotificationNavigator.navigatorKey.currentContext;

    if (nav != null) {
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired due to a server update. Please log in again.'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  // Called on app start — check if already logged in and restore session
  Future<void> tryAutoLogin() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      _user = null;
      notifyListeners();
      return;
    }

    // 1. Immediately restore cached user so UI doesn't flicker or show login screen
    final cached = await _authService.getCachedUser();
    if (cached != null) {
      _user = cached;
      notifyListeners();
    }

    // 2. Verify with backend (/auth/me). If 401/422 (e.g. backend redeployed),
    // getCurrentUser returns null and clears storage. On network glitch, it preserves cached user.
    final freshUser = await _authService.getCurrentUser();
    if (freshUser != null) {
      _user = freshUser;
    } else {
      _user = null;
    }
    notifyListeners();
  }

  String _extractErrorMessage(dynamic e, String defaultMsg) {
    if (e is DioException) {
      if (e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          if (data.containsKey('message') && data['message'] != null) {
            return data['message'].toString();
          }
          if (data.containsKey('detail') && data['detail'] != null) {
            return data['detail'].toString();
          }
          if (data.containsKey('error') && data['error'] != null) {
            return data['error'].toString();
          }
        } else if (data is String && data.isNotEmpty) {
          if (data.contains('<html') || data.contains('<!doctype')) {
            return '$defaultMsg (Server error ${e.response?.statusCode})';
          }
          return data;
        }
        return '$defaultMsg (HTTP ${e.response?.statusCode})';
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return 'Cannot connect to backend server. Please check IP & network connection.';
      }
      return 'Network error: ${e.message}';
    }
    return defaultMsg;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error     = '';
    notifyListeners();

    try {
      _user = await _authService.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error     = _extractErrorMessage(e, 'Invalid email or password');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
    String  role       = 'TECHNICIAN',
    String? department,
  }) async {
    _isLoading = true;
    _error     = '';
    notifyListeners();

    try {
      _user = await _authService.signUp(
        fullName:   fullName,
        email:      email,
        password:   password,
        role:       role,
        department: department,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error     = _extractErrorMessage(e, 'Registration failed. Please check your details.');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
