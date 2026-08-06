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
      _error     = 'Invalid email or password';
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
