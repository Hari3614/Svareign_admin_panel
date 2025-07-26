import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      role: data['role'],
      latitude: data['location']['latitude'],
      longitude: data['location']['longitude'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
