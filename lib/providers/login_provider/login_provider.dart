import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginProvider extends ChangeNotifier {
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;

  void setEmail(String value) {
    _email = value.trim();
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value.trim();
    notifyListeners();
  }

  Future<bool> login() async {
    try {
      _isLoading = true;
      notifyListeners();
      log("---- LOGIN START ----");
      log("Email entered: $_email");
      log("Password entered: $_password");

      // 1. Sign in user
      final authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      log("Firebase Auth Success");
      log("User UID: ${authResult.user!.uid}");

      final uid = authResult.user!.uid;

      // 2. Check admin role
      log("Fetching admin document for UID: $uid");

      final adminDoc =
          await FirebaseFirestore.instance.collection('admins').doc(uid).get();

      log("Admin doc exists: ${adminDoc.exists}");

      if (adminDoc.exists) {
        log("Admin doc data: ${adminDoc.data()}");
        log("Role found: ${adminDoc.data()?['role']}");
      }

      _isLoading = false;
      notifyListeners();

      if (adminDoc.exists && adminDoc.data()?['role'] == 'admin') {
        log("---- ADMIN LOGIN SUCCESS ----");
        return true;
      }

      log("---- LOGIN FAILED: NOT ADMIN ----");
      return false;
    } catch (e) {
      log("---- LOGIN ERROR ----");
      log("Error: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
