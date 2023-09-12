//for all firebase related services for user
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_delivery_app/models/user_model.dart';

class UserServices {
  String collection = 'users';
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserData(Map<String, dynamic> userData) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userData['id'])
        .set(userData);
  }

  Future<void> updateUserData(Map<String, dynamic> userData) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userData['id'])
        .update(userData);
  }

//get user data by user id
  Future<DocumentSnapshot> getUserById(String id) async {
    var result = await _firestore.collection(collection).doc(id).get();

    return result;
  }
}
