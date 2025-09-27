// lib/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetches recent notifications for a specific user.
  // This assumes notifications are stored in a subcollection under each user's document.
  Future<List<AppNotification>> getNotificationsForUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(5) // Get the 5 most recent notifications
          .get();

      return snapshot.docs.map((doc) => AppNotification.fromFirestore(doc)).toList();
    } catch (e) {
      // In a real app, you'd use a logging service here.
      // print('Error fetching notifications: $e');
      return [];
    }
  }
}

