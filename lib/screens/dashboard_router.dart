import 'package:flutter/material.dart';
import 'package:smart_curricular_activity_attendance_app/models/user_model.dart';
import 'student_dashboard_screen.dart';
import 'lecturer_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';

class DashboardRouter extends StatelessWidget {
  final AppUser user;
  const DashboardRouter({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    switch (user.role) {
      case 'Student':
        return StudentDashboardScreen(user: user);
      case 'Lecturer':
        return LecturerDashboardScreen(user: user);
      case 'Admin':
        return AdminDashboardScreen(user: user);
      default:
        return Scaffold(
          body: Center(child: Text('Unknown role: ${user.role}')),
        );
    }
  }
}