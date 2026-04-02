import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;

  // Mock login method
  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simule l'appel réseau
    _isAuthenticated = true;
    _userId = "mock_user_123";
    notifyListeners();
  }

  // Mock logout method
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isAuthenticated = false;
    _userId = null;
    notifyListeners();
  }
}
