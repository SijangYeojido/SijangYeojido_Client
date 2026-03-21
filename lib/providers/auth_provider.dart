import 'package:flutter/material.dart';

enum UserRole { customer, merchant }

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  UserRole _role = UserRole.customer;
  String? _userName;

  bool get isLoggedIn => _isLoggedIn;
  UserRole get role => _role;
  String? get userName => _userName;

  void login(String email, String password, UserRole role) {
    // Mock login logic
    _isLoggedIn = true;
    _role = role;
    _userName = role == UserRole.merchant ? '사장님' : '사용자';
    notifyListeners();
  }

  void signup(String email, String password, String name, UserRole role) {
    // Mock signup logic
    _isLoggedIn = true;
    _role = role;
    _userName = name;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _role = UserRole.customer;
    _userName = null;
    notifyListeners();
  }

  void toggleRole() {
    _role = _role == UserRole.customer ? UserRole.merchant : UserRole.customer;
    notifyListeners();
  }
}
