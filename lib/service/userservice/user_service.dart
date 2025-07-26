import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:svareignadmin/model/usermodel/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> fetchUsers() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection("users").get();

      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    } on FirebaseException catch (e) {
      print("FirebaseException: ${e.message}");
      rethrow; // Don't try to treat it as a JS object
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }
}
