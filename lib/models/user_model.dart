// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String role;
  final String name;
  final String studentId;   // Field for student ID number
  final String section;     // Field for class section (e.g., "12 A")
  final int activityPoints; // Field for tracking points

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    this.studentId = '', // Provide default values to prevent null errors
    this.section = '',
    this.activityPoints = 0,
  });

  // A factory constructor to create an AppUser instance from a Firestore document.
  // This is crucial for reading user data from the database.
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'Student',
      name: data['name'] ?? '',
      studentId: data['studentId'] ?? '',
      section: data['section'] ?? '',
      activityPoints: data['activityPoints'] ?? 0,
    );
  }
}
