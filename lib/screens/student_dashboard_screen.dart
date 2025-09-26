import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/attendance_record_model.dart';
import '../services/auth_service.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() { _loading = true; _error = null; });
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

      setState(() { _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
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
            Text(
              'Recent Attendance Records',
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
                  return ListTile(
                    leading: Icon(
                      record.status == 'Present'
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: record.status == 'Present'
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: Text('Session: ${record.sessionId}'),
                    subtitle: Text(
                      'Status: ${record.status}\n'
                          'Marked at: ${record.markedAt}',
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
      color: color.withOpacity(0.1),
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