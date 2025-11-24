import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:svareignadmin/model/user_model/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches all users from Firestore 'users' collection
  /// Returns a list of [UserModel]
  /// Throws [FirebaseException] if Firestore fails
  Future<List<UserModel>> fetchUsers() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('users').get();

      if (snapshot.docs.isEmpty) {
        log('No users found in Firestore.');
        return [];
      }

      final users =
          snapshot.docs
              .map(
                (doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();

      log('Fetched ${users.length} users from Firestore.');
      return users;
    } on FirebaseException catch (e) {
      // Firestore-specific errors
      log('FirebaseException while fetching users: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      // Any other errors
      log('Unexpected error while fetching users: $e');
      log(stackTrace as String);
      rethrow;
    }
  }

  /// Fetch a single user by UID
  Future<UserModel?> fetchUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        log('User with UID $uid not found.');
        return null;
      }

      return UserModel.fromMap(doc.data()!);
    } on FirebaseException catch (e) {
      log('FirebaseException while fetching user $uid: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      log('Unexpected error while fetching user $uid: $e');
      log(stackTrace as String);
      rethrow;
    }
  }
}