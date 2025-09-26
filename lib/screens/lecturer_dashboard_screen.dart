import 'package:flutter/material.dart';
import 'package:smart_curricular_activity_attendance_app/models/user_model.dart';

class LecturerDashboardScreen extends StatelessWidget {
  final AppUser user;
  const LecturerDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lecturer Dashboard')),
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