// lib/services/activity_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_record_model.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetches recent activities for a specific user.
  // This assumes activities are stored in a subcollection under each user's document.
  Future<List<ActivityRecord>> getRecentActivitiesForUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('activities')
          .orderBy('date', descending: true)
          .limit(3) // Get the 3 most recent activities
          .get();

      return snapshot.docs.map((doc) => ActivityRecord.fromFirestore(doc)).toList();
    } catch (e) {
      // In a real app, you'd use a logging service here.
      // print('Error fetching activities: $e');
      return [];
    }
  }
}

