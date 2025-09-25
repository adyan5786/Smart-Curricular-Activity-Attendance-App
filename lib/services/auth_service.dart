// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Signs in a user with email and password and then verifies their role from Firestore.
  /// Returns a Firebase User object on complete success, or null on any failure.
  Future<User?> signInWithEmail(String email, String password, String selectedRole) async {
    try {
      // Step 1: Authenticate the user's credentials with Firebase Auth.
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Step 2: If authentication is successful, authorize the user by checking their role in Firestore.
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists && userDoc.get('role') == selectedRole) {
          // Success: Credentials are valid AND the role matches.
          return user;
        } else {
          // Authorization failed: Credentials were correct, but the role doesn't match or the user document is missing.
          // For security, we sign the user out immediately to prevent partial access.
          await _auth.signOut();
          return null;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      // This block catches specific authentication errors, like 'wrong-password' or 'user-not-found'.
      // This allows the UI to show a more specific error message to the user.
      print('Firebase Auth Exception: ${e.message}');
      return null;
    } catch (e) {
      // A general catch block for any other unexpected errors (e.g., network issues).
      print('An unexpected error occurred: $e');
      return null;
    }
  }

  /// Sends a password reset email using Firebase's built-in service.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Password reset error: ${e.message}');
      // The UI can use this to inform the user if the email doesn't exist.
    }
  }
}