// lib/services/attendance_service.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_session_model.dart';

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
  Future<String?> startAttendanceSession(String classSessionId) async {
    try {
      String token = _generateToken();
      DateTime expiresAt = DateTime.now().add(const Duration(minutes: 5));

      await _firestore.collection('active_attendance_sessions').doc(classSessionId).set({
        'token': token,
        'expiresAt': Timestamp.fromDate(expiresAt),
        'classSessionId': classSessionId,
      });

      return token;
    } catch (e) {
      // print('Error starting attendance session: $e');
      return null;
    }
  }

  /// [Student Function]
  /// Marks a student as present for a class session by validating the submitted token.
  Future<String> markPresent(String classSessionId, String studentId, String submittedToken) async {
    try {
      DocumentSnapshot sessionDoc = await _firestore.collection('active_attendance_sessions').doc(classSessionId).get();

      if (!sessionDoc.exists) {
        return 'Attendance session not found or has ended.';
      }

      Map<String, dynamic> sessionData = sessionDoc.data() as Map<String, dynamic>;
      String correctToken = sessionData['token'];
      DateTime expiresAt = (sessionData['expiresAt'] as Timestamp).toDate();

      if (submittedToken != correctToken) {
        return 'Invalid attendance code.';
      }

      if (DateTime.now().isAfter(expiresAt)) {
        await sessionDoc.reference.delete();
        return 'Attendance code has expired.';
      }

      String recordId = '${classSessionId}_$studentId';
      await _firestore.collection('attendance_records').doc(recordId).set({
        'sessionId': classSessionId,
        'studentId': studentId,
        'markedAt': Timestamp.now(),
        'status': 'Present',
      }, SetOptions(merge: true));

      return 'Success';
    } catch (e) {
      // print('Error marking present: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // NEW METHOD 1 FOR THE DASHBOARD
  Future<String> getTodaysAttendanceStatus(String userId, List<ClassSession> todaysClasses) async {
    if (todaysClasses.isEmpty) {
      return 'No classes today';
    }

    int attendedCount = 0;
    for (var session in todaysClasses) {
      final recordId = '${session.id}_$userId';
      final doc = await _firestore.collection('attendance_records').doc(recordId).get();
      if (doc.exists && doc.get('status') == 'Present') {
        attendedCount++;
      }
    }

    if (attendedCount == todaysClasses.length) {
      return 'Present';
    } else {
      return 'Absent'; // Simplified for the main status card
    }
  }

  // NEW METHOD 2 FOR THE DASHBOARD
  Future<double> getMonthlyAttendanceRate(String userId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final totalClassesSnapshot = await _firestore
          .collection('class_sessions')
          .where('studentIds', arrayContains: userId)
          .where('startTime', isGreaterThanOrEqualTo: startOfMonth)
          .get();

      final totalClasses = totalClassesSnapshot.docs.length;
      if (totalClasses == 0) return 100.0; // Avoid division by zero

      final attendedClassesSnapshot = await _firestore
          .collection('attendance_records')
          .where('studentId', isEqualTo: userId)
          .where('status', isEqualTo: 'Present')
          .where('markedAt', isGreaterThanOrEqualTo: startOfMonth)
          .get();

      final attendedClasses = attendedClassesSnapshot.docs.length;

      return (attendedClasses / totalClasses) * 100;
    } catch (e) {
      // print('Error calculating attendance rate: $e');
      return 0.0;
    }
  }
}

