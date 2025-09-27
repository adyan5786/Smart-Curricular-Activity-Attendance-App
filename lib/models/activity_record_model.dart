// lib/models/activity_record_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityRecord {
  final String id;
  final String title;
  final DateTime date;
  final int points;

  ActivityRecord({
    required this.id,
    required this.title,
    required this.date,
    required this.points,
  });

  factory ActivityRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ActivityRecord(
      id: doc.id,
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      points: data['points'] ?? 0,
    );
  }
}

