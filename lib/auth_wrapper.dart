// lib/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_curricular_activity_attendance_app/models/user_model.dart';
import 'package:smart_curricular_activity_attendance_app/services/auth_service.dart';
import 'package:smart_curricular_activity_attendance_app/services/user_service.dart';
import 'package:smart_curricular_activity_attendance_app/screens/login_screen.dart';
import 'package:smart_curricular_activity_attendance_app/screens/student_dashboard_screen.dart';
import 'package:smart_curricular_activity_attendance_app/screens/lecturer_dashboard_screen.dart';
import 'package:smart_curricular_activity_attendance_app/screens/admin_dashboard_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final userService = UserService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (authSnapshot.hasData) {
          // User is logged in, now fetch their user profile data from Firestore.
          return FutureBuilder<AppUser?>(
            future: userService.getUser(authSnapshot.data!.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (userSnapshot.hasError || !userSnapshot.hasData || userSnapshot.data == null) {
                // If there's an error or no user data, send them to login.
                return const LoginScreen();
              }

              // User data loaded successfully, route to the correct dashboard.
              final user = userSnapshot.data!;
              switch (user.role) {
                case 'Admin':
                  return AdminDashboardScreen(user: user);
                case 'Lecturer':
                  return LecturerDashboardScreen(user: user);
                case 'Student':
                default:
                  return StudentDashboardScreen(user: user);
              }
            },
          );
        }
        // User is logged out.
        return const LoginScreen();
      },
    );
  }
}
