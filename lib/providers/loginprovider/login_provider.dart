// lib/providers/login_provider.dart
import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier {
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  Future<bool> login() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(seconds: 2)); // Simulated network delay
    _isLoading = false;
    notifyListeners();
    return _email == 'admin@example.com' && _password == 'admin123';
  }
}
