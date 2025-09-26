// lib/services/timetable_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
// Corrected relative imports
import '../models/class_session_model.dart';
import '../models/user_model.dart';

class TimetableService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches the full weekly schedule for a given user.
  Future<List<ClassSession>> getScheduleForUser(AppUser user) async {
    try {
      QuerySnapshot querySnapshot;
      if (user.role == 'Student') {
        querySnapshot = await _firestore
            .collection('class_sessions')
            .where('studentIds', arrayContains: user.uid)
            .get();
      } else if (user.role == 'Teacher') {
        querySnapshot = await _firestore
            .collection('class_sessions')
            .where('teacherId', isEqualTo: user.uid)
            .get();
      } else {
        return [];
      }
      return querySnapshot.docs.map((doc) => ClassSession.fromFirestore(doc)).toList();
    } catch (e) {
      // print('Error fetching schedule: $e');
      return [];
    }
  }

  /// Creates a new, unassigned class session in Firestore.
  Future<void> createClassSession(String subjectName, String location, String teacherId) async {
    try {
      await _firestore.collection('class_sessions').add({
        'subjectName': subjectName,
        'location': location,
        'teacherId': teacherId,
        'dayOfWeek': 'Unassigned',
        'startTime': Timestamp.now(), // Placeholder time
        'endTime': Timestamp.now(),   // Placeholder time
        'studentIds': [],
      });
    } catch (e) {
      // print('Error creating class session: $e');
    }
  }

  /// Updates the time and day for a specific class session (for drag-and-drop).
  Future<void> updateClassSessionTime(String sessionId, String newDayOfWeek, DateTime newStartTime, DateTime newEndTime) async {
    try {
      await _firestore.collection('class_sessions').doc(sessionId).update({
        'dayOfWeek': newDayOfWeek,
        'startTime': Timestamp.fromDate(newStartTime),
        'endTime': Timestamp.fromDate(newEndTime),
      });
    } catch (e) {
      // print('Error updating class session: $e');
    }
  }

  /// Deletes a class session from Firestore.
  Future<void> deleteClassSession(String sessionId) async {
    try {
      await _firestore.collection('class_sessions').doc(sessionId).delete();
    } catch (e) {
      // print('Error deleting class session: $e');
    }
  }
}

