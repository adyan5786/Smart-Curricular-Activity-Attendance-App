// lib/services/attendance_service.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generates a random 6-digit numeric token as a string.
  String _generateToken() {
    var rng = Random();
    // Generates a number between 100000 and 999999
    return (100000 + rng.nextInt(900000)).toString();
  }

  /// [Teacher Function]
  /// Starts an attendance session for a specific class.
  /// This creates a temporary document in Firestore with a unique token that is valid for 5 minutes.
  /// Returns the generated token so the UI can display it in a QR code.
  Future<String?> startAttendanceSession(String classSessionId) async {
    try {
      String token = _generateToken();
      DateTime expiresAt = DateTime.now().add(const Duration(minutes: 5));

      // Use the classSessionId as the document ID for the active session.
      // This makes it easy to look up and prevents multiple active sessions for the same class.
      await _firestore.collection('active_attendance_sessions').doc(classSessionId).set({
        'token': token,
        'expiresAt': Timestamp.fromDate(expiresAt),
        'classSessionId': classSessionId,
      });

      return token;
    } catch (e) {
      print('Error starting attendance session: $e');
      return null;
    }
  }

  /// [Student Function]
  /// Marks a student as present for a class session by validating the submitted token.
  /// Returns a String message indicating success or the specific reason for failure.
  Future<String> markPresent(String classSessionId, String studentId, String submittedToken) async {
    try {
      // Step 1: Get the active session details from Firestore.
      DocumentSnapshot sessionDoc = await _firestore.collection('active_attendance_sessions').doc(classSessionId).get();

      if (!sessionDoc.exists) {
        return 'Attendance session not found or has ended.';
      }

      Map<String, dynamic> sessionData = sessionDoc.data() as Map<String, dynamic>;
      String correctToken = sessionData['token'];
      DateTime expiresAt = (sessionData['expiresAt'] as Timestamp).toDate();

      // Step 2: Validate the token and its expiry.
      if (submittedToken != correctToken) {
        return 'Invalid attendance code.';
      }

      if (DateTime.now().isAfter(expiresAt)) {
        // Good practice: delete the expired session document to keep the collection clean.
        await sessionDoc.reference.delete();
        return 'Attendance code has expired.';
      }

      // Step 3: If token is valid, create (or update) the attendance record.
      // We use a predictable document ID to prevent duplicate entries if a student scans twice.
      String recordId = '${classSessionId}_${studentId}';
      await _firestore.collection('attendance_records').doc(recordId).set({
        'sessionId': classSessionId,
        'studentId': studentId,
        'markedAt': Timestamp.now(),
        'status': 'Present',
      }, SetOptions(merge: true)); // Use merge to avoid overwriting if a record somehow exists.

      return 'Success';
    } catch (e) {
      print('Error marking present: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }
}