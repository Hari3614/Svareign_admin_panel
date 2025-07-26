import 'package:flutter/material.dart';
import 'package:svareignadmin/model/usermodel/user_model.dart';
import 'package:svareignadmin/service/userservice/user_service.dart';

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
      print("Error fetching users: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
