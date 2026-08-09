import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();

  User?  _user;
  bool   _isLoading = false;
  String _error     = '';

  User?  get user      => _user;
  bool   get isLoading => _isLoading;
  String get error     => _error;
  bool   get isLoggedIn => _user != null;

  // Called on app start — check if already logged in
  Future<void> tryAutoLogin() async {
    final loggedIn = await _authService.isLoggedIn();
    if (loggedIn) {
      _user = await _authService.getCurrentUser();
      notifyListeners();
    }
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
    String role = 'TECHNICIAN',
  }) async {
    _isLoading = true;
    _error     = '';
    notifyListeners();

    try {
      _user = await _authService.signUp(
        fullName: fullName,
        email:    email,
        password: password,
        role:     role,
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
