import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_curricular_activity_attendance_app/models/user_model.dart';
import 'package:smart_curricular_activity_attendance_app/services/auth_service.dart';
import 'package:smart_curricular_activity_attendance_app/services/attendance_service.dart';

class LecturerDashboardScreen extends StatefulWidget {
  final AppUser user;
  const LecturerDashboardScreen({super.key, required this.user});

  @override
  State<LecturerDashboardScreen> createState() => _LecturerDashboardScreenState();
}

class _LecturerDashboardScreenState extends State<LecturerDashboardScreen> {
  String? _activeSessionId;
  String? _activeToken;
  String? _qrData;
  bool _loading = false;
  String? _statusMsg;

  Future<void> _startAttendanceSession() async {
    setState(() {
      _loading = true;
      _statusMsg = null;
      _qrData = null;
      _activeSessionId = null;
      _activeToken = null;
    });

    try {
      // For demo, ask the user for a class/session ID.
      final classSessionId = await _askSessionId();
      if (classSessionId == null || classSessionId.isEmpty) {
        setState(() {
          _loading = false;
          _statusMsg = "Session ID is required.";
        });
        return;
      }

      final token = await AttendanceService().startAttendanceSession(classSessionId);
      if (token == null) {
        setState(() {
          _loading = false;
          _statusMsg = "Failed to start attendance session.";
        });
        return;
      }

      final qrPayload = {
        "classSessionId": classSessionId,
        "token": token,
      };

      setState(() {
        _activeSessionId = classSessionId;
        _activeToken = token;
        _qrData = qrPayload.toString(); // If your student app expects JSON, use jsonEncode(qrPayload)
        _statusMsg = "Session started! Show QR to students.";
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _statusMsg = "Error: $e";
      });
    }
  }

  Future<String?> _askSessionId() async {
    String? input;
    await showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text("Enter Class Session ID"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "e.g., CS101-Mon-9am"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                input = controller.text.trim();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return input;
  }

  Future<void> _endAttendanceSession() async {
    if (_activeSessionId == null) return;
    setState(() {
      _loading = true;
      _statusMsg = null;
    });
    try {
      // Remove active session from Firestore
      await FirebaseFirestore.instance
          .collection('active_attendance_sessions')
          .doc(_activeSessionId)
          .delete();
      setState(() {
        _activeSessionId = null;
        _activeToken = null;
        _qrData = null;
        _statusMsg = "Attendance session ended.";
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _statusMsg = "Error ending session: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _statusMsg = null;
              });
            },
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
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome Lecturer, ${widget.user.name}!\nHere you can manage attendance sessions.',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _loading
                    ? const CircularProgressIndicator()
                    : _activeSessionId == null
                    ? ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code),
                  label: const Text("Start Attendance Session & Generate QR"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(250, 48),
                    backgroundColor: Colors.deepPurple,
                  ),
                  onPressed: _startAttendanceSession,
                )
                    : Column(
                  children: [
                    Text(
                      "Active Session: $_activeSessionId",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Share this QR with students to mark attendance:",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    QrImageView(
                      data: '{"classSessionId":"$_activeSessionId","token":"$_activeToken"}',
                      version: QrVersions.auto,
                      size: 220.0,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.stop_circle),
                      label: const Text("End Session"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(180, 44),
                      ),
                      onPressed: _endAttendanceSession,
                    ),
                  ],
                ),
                if (_statusMsg != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    _statusMsg!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}