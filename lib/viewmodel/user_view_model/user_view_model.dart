import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:svareignadmin/model/user_model/user_model.dart';
import 'package:svareignadmin/service/user_service/user_service.dart';

class UserViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  List<UserModel> _users = [];
  bool _isLoading = false;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _userService.fetchUsers();
    } catch (e) {
      log("Error fetching users: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
