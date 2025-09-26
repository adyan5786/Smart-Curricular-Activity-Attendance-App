// lib/models/class_session_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassSession {
  final String id;
  final String subjectName;
  final String teacherId;
  final String location;
  final String dayOfWeek; // e.g., "Monday", "Tuesday"
  final DateTime startTime;
  final DateTime endTime;
  final List<String> studentIds;

  ClassSession({
    required this.id,
    required this.subjectName,
    required this.teacherId,
    required this.location,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.studentIds,
  });

  factory ClassSession.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ClassSession(
      id: doc.id,
      subjectName: data['subjectName'] ?? '',
      teacherId: data['teacherId'] ?? '',
      location: data['location'] ?? '',
      dayOfWeek: data['dayOfWeek'] ?? 'Monday',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      studentIds: List<String>.from(data['studentIds'] ?? []),
    );
  }
}

