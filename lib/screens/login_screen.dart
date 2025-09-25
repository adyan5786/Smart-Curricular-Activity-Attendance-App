import 'package:smart_curricular_activity_attendance_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // A key to identify and validate our Form
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // Controllers to manage the text input for email and password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State variable to hold the currently selected role from the dropdown
  String _selectedRole = 'Student';
  final List<String> _roles = ['Student', 'Lecturer', 'Admin'];

  // State variable to track the loading status for the login process
  bool _isLoading = false;

  // It's good practice to dispose of controllers when the widget is removed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Dummy login function for UI development
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
        // Successful login! Navigate to the home screen.
        // Navigator.of(context).pushReplacement(...);
        print('Login successful for user: ${user.uid}');
      } else {
        // Failed login. Show an error message.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Failed. Please check your credentials and role.')),
        );
      }
    }
  }

  // Placeholder navigation functions
  void _goToSignUp() {
    print('Navigate to Sign Up Screen');
  }

  void _forgotPassword() {
    print('Navigate to Forgot Password Screen');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Use a ListView to prevent overflow on smaller screens
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              // Email Text Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
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
              const SizedBox(height: 20),
              // Password Text Field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Role Dropdown
              DropdownButtonFormField<String>(
                // FIX: Replaced 'value' with 'initialValue' to resolve the deprecation warning.
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
              const SizedBox(height: 30),
              // Login Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                // Disable button when loading
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : const Text('Login', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 10),
              // Other Actions
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
            ],
          ),
        ),
      ),
    );
  }
}

