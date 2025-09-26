import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Make sure this import is present

// Import your login screen
import 'package:smart_curricular_activity_attendance_app/screens/login_screen.dart';

void main() async { // 1. Make the main function async
  // 2. Ensure Flutter is ready before calling native code
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 4. Now, run your app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginScreen(), // Your starting screen
    );
  }
}