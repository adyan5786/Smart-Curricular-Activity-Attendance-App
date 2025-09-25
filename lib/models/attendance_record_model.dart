// lib/models/attendance_record_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String id; // Document ID
  final String sessionId; // ID of the ClassSession
  final String studentId;
  final DateTime markedAt;
  final String status; // e.g., "Present", "Absent", "Late"

  AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.markedAt,
    required this.status,
  });

  // While we are mostly writing data with this model, having a
  // fromFirestore factory is good practice for potential future features.
  factory AttendanceRecord.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return AttendanceRecord(
      id: doc.id,
      sessionId: data['sessionId'] ?? '',
      studentId: data['studentId'] ?? '',
      markedAt: (data['markedAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'Absent',
    );
  }
}
