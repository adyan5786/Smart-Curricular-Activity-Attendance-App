import 'package:flutter/material.dart';
import 'package:smart_curricular_activity_attendance_app/models/user_model.dart';
import 'package:smart_curricular_activity_attendance_app/services/auth_service.dart';

class LecturerDashboardScreen extends StatelessWidget {
  final AppUser user;
  const LecturerDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Placeholder for data refresh logic
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
      body: Center(
        child: Text(
          'Welcome Lecturer, ${user.name}!\n\n'
              'Here you can manage attendance sessions.',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

