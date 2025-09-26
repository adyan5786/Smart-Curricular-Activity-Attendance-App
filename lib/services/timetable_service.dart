// lib/services/timetable_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_session_model.dart';
import '../models/user_model.dart'; // We'll need the user's role

class TimetableService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches the weekly schedule for a given user.
  /// It determines whether to fetch a student's or teacher's schedule based on their role.
  Future<List<ClassSession>> getScheduleForUser(AppUser user) async {
    try {
      QuerySnapshot querySnapshot;
      if (user.role == 'Student') {
        // For students, find all classes where their ID is in the 'studentIds' array.
        querySnapshot = await _firestore
            .collection('class_sessions')
            .where('studentIds', arrayContains: user.uid)
            .get();
      } else if (user.role == 'Teacher') {
        // For teachers, find all classes where their ID matches the 'teacherId'.
        querySnapshot = await _firestore
            .collection('class_sessions')
            .where('teacherId', isEqualTo: user.uid)
            .get();
      } else {
        // If the role is neither, return an empty list.
        return [];
      }

      // Convert the Firestore documents into a list of ClassSession objects.
      return querySnapshot.docs
          .map((doc) => ClassSession.fromFirestore(doc))
          .toList();

    } catch (e) {
      print('Error fetching schedule: $e');
      return []; // Return an empty list on error.
    }
  }

  /// [Teacher Function] Creates a new class session document in Firestore.
  /// Returns the ID of the new document if successful.
  Future<String?> createClassSession({
    required String subjectName,
    required String teacherId,
    required String location,
  }) async {
    try {
      DocumentReference docRef = await _firestore.collection('class_sessions').add({
        'subjectName': subjectName,
        'teacherId': teacherId,
        'location': location,
        'dayOfWeek': 'Unassigned', // Initially unassigned
        'startTime': Timestamp.now(), // Placeholder time
        'endTime': Timestamp.now(),   // Placeholder time
        'studentIds': [], // Starts with no students
      });
      return docRef.id;
    } catch (e) {
      print('Error creating class session: $e');
      return null;
    }
  }

  /// [Teacher Function] Updates an existing class session, typically after a drag-and-drop action.
  Future<void> updateClassSessionTime(
      String sessionId,
      String newDayOfWeek,
      DateTime newStartTime,
      DateTime newEndTime,
      ) async {
    try {
      await _firestore.collection('class_sessions').doc(sessionId).update({
        'dayOfWeek': newDayOfWeek,
        'startTime': Timestamp.fromDate(newStartTime),
        'endTime': Timestamp.fromDate(newEndTime),
      });
    } catch (e) {
      print('Error updating class session: $e');
    }
  }

  /// [Teacher Function] Deletes a class session document from Firestore.
  Future<void> deleteClassSession(String sessionId) async {
    try {
      await _firestore.collection('class_sessions').doc(sessionId).delete();
    } catch (e) {
      print('Error deleting class session: $e');
    }
  }
}
