// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_curricular_activity_attendance_app/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
    return null;
  }
}