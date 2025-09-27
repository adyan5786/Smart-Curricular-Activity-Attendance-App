import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert'; // <-- Needed for jsonDecode
import '../models/user_model.dart';
import '../models/attendance_record_model.dart';
import '../services/auth_service.dart';
import 'student_qr_scanner_screen.dart';
import '../services/attendance_service.dart';

class StudentDashboardScreen extends StatefulWidget {
  final AppUser user;
  const StudentDashboardScreen({super.key, required this.user});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _attendanceCount = 0;
  int _activityCount = 0;
  List<AttendanceRecord> _recentRecords = [];
  bool _loading = true;
  String? _error;
  bool _isMarkingAttendance = false; // <-- Move here

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Attendance records for this user (Student)
      final attendanceSnapshots = await FirebaseFirestore.instance
          .collection('attendance_records')
          .where('studentId', isEqualTo: widget.user.uid)
          .orderBy('markedAt', descending: true)
          .limit(10)
          .get();

      final records = attendanceSnapshots.docs
          .map((doc) => AttendanceRecord.fromFirestore(doc))
          .toList();

      _attendanceCount = records.length;
      _activityCount = records.map((r) => r.sessionId).toSet().length;
      _recentRecords = records;

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openQRScanner() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentQRScannerScreen(
          onScan: (qrData) async {
            await _handleQRData(qrData);
          },
        ),
      ),
    );
  }

  Future<void> _handleQRData(String qrData) async {
    setState(() {
      _isMarkingAttendance = true;
    });

    String feedback;
    try {
      // Assume QR contains classSessionId and token in a simple format, e.g.:
      // { "classSessionId": "...", "token": "..." }
      final Map<String, dynamic> parsed = _parseQR(qrData);
      final classSessionId = parsed['classSessionId'];
      final token = parsed['token'];

      if (classSessionId == null || token == null) {
        feedback = "Invalid QR code format.";
      } else {
        final result = await AttendanceService().markPresent(
          classSessionId,
          widget.user.uid,
          token,
        );
        feedback = result == "Success"
            ? "Attendance marked successfully!"
            : result;
        await _fetchDashboardData();
      }
    } catch (e) {
      feedback = "Failed to mark attendance: $e";
    }

    if (mounted) {
      setState(() {
        _isMarkingAttendance = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(feedback)));
    }
  }

  // Minimal parser for JSON or simple delimited QR codes
  Map<String, dynamic> _parseQR(String qrData) {
    try {
      // Try parsing JSON
      return Map<String, dynamic>.from(
        qrData.contains('{')
            ? (qrData.isNotEmpty
            ? (qrData.startsWith('{')
            ? (qrData.endsWith('}')
            ? (qrData == '{}'
            ? {}
            : Map<String, dynamic>.from(
          jsonDecode(qrData),
        ))
            : {})
            : {})
            : {})
            : _parseDelimited(qrData),
      );
    } catch (_) {
      // Try fallback
      return _parseDelimited(qrData);
    }
  }

  Map<String, dynamic> _parseDelimited(String qrData) {
    // Fallback for e.g. "classSessionId:xyz;token:123456"
    final parts = qrData.split(';');
    final data = <String, dynamic>{};
    for (final part in parts) {
      final kv = part.split(':');
      if (kv.length == 2) data[kv[0].trim()] = kv[1].trim();
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Student Dashboard')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Student Dashboard')),
        body: Center(child: Text('Error: $_error')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDashboardData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await AuthService().signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${widget.user.name}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Attendance', _attendanceCount, Colors.deepPurple),
                _buildStatCard('Activities', _activityCount, Colors.blue),
              ],
            ),
            const SizedBox(height: 32),
            // Move the button here!
            ElevatedButton.icon(
              onPressed: _isMarkingAttendance ? null : _openQRScanner,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Scan QR to Mark Attendance"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            if (_isMarkingAttendance)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: LinearProgressIndicator(),
              ),
            const SizedBox(height: 32),
            Text(
              'Recent Attendance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _recentRecords.isEmpty
                  ? const Center(child: Text('No recent records found.'))
                  : ListView.builder(
                itemCount: _recentRecords.length,
                itemBuilder: (context, idx) {
                  final record = _recentRecords[idx];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        record.status == 'Present'
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: record.status == 'Present'
                            ? Colors.green
                            : Colors.red,
                      ),
                      title: Text('Session: ${record.sessionId}'),
                      subtitle: Text('Status: ${record.status}'),
                      trailing: Text(
                        '${record.markedAt.toLocal()}'.split(' ')[0],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Card(
      color: color.withAlpha(26),
      child: SizedBox(
        width: 140,
        height: 100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 32,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}