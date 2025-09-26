import 'package:smart_curricular_activity_attendance_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:smart_curricular_activity_attendance_app/screens/signup_screen.dart';
import 'package:smart_curricular_activity_attendance_app/screens/forgot_password_screen.dart';
import 'package:smart_curricular_activity_attendance_app/screens/student_dashboard_screen.dart';
import 'package:smart_curricular_activity_attendance_app/screens/lecturer_dashboard_screen.dart';
import 'package:smart_curricular_activity_attendance_app/screens/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedRole = 'Student';
  final List<String> _roles = ['Student', 'Lecturer', 'Admin'];
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      final user = await _authService.signInWithEmail(
        _emailController.text,
        _passwordController.text,
        _selectedRole,
      );

      setState(() { _isLoading = false; });

      if (user != null) {
        print('Login successful for user: ${user.uid}');
        // Fetch user details from Firestore (including role)
        final userDetails = await _authService.getCurrentUserDetails();

        if (userDetails != null && mounted) {
          Widget dashboard;
          switch (userDetails.role) {
            case 'Student':
              dashboard = StudentDashboardScreen(user: userDetails);
              break;
            case 'Lecturer':
              dashboard = LecturerDashboardScreen(  user: userDetails);
              break;
            case 'Admin':
              dashboard = const AdminDashboardScreen();
              break;
            default:
              dashboard = const Scaffold(body: Center(child: Text('Unknown user role')));
          }
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => dashboard),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Failed. Please check your credentials and role.')),
        );
      }
    }
  }

  void _goToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  void _forgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double horizontalPadding = screenWidth * 0.07; // 7% padding left/right

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400, // Prevent super wide layouts on tablets
                ),
                child: Form(
                  key: _formKey,
                  // STEP 1: Wrap the Column with AutofillGroup
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: screenHeight * 0.04),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          // STEP 2: Add autofill hints for email
                          autofillHints: const [AutofillHints.email],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.025),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          // STEP 3: Add autofill hints and onEditingComplete for password
                          autofillHints: const [AutofillHints.password],
                          onEditingComplete: _login,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.025),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Role',
                            prefixIcon: Icon(Icons.person_search),
                            border: OutlineInputBorder(),
                          ),
                          items: _roles.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedRole = newValue!;
                            });
                          },
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 48), // full width, good touch target
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2.5,
                            ),
                          )
                              : const Text('Login', style: TextStyle(fontSize: 16)),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _forgotPassword,
                              child: const Text('Forgot Password?'),
                            ),
                            TextButton(
                              onPressed: _goToSignUp,
                              child: const Text('Sign Up'),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
