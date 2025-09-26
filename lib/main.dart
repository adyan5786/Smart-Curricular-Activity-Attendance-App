import 'package:flutter/material.dart';
import 'package:smart_curricular_activity_attendance_app/screens/login_screen.dart'; // Import your login screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCAA App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Set the LoginScreen as the first screen the user sees
      home: const LoginScreen(),
    );
  }
}
