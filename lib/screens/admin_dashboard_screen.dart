import 'package:flutter/material.dart';
import 'package:smart_curricular_activity_attendance_app/models/user_model.dart';
import 'package:smart_curricular_activity_attendance_app/services/auth_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  final AppUser user;
  const AdminDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await AuthService().signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome, ${user.name}! (Admin)\n\nDashboard coming soon!'),
      ),
    );
  }
}
