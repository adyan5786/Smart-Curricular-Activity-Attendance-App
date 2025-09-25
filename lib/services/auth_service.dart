// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// A stream that notifies the app about changes in the user's authentication state.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

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

  /// Registers a new user with email and password, then saves their details to Firestore.
  /// Returns a Firebase User object on success, or null on failure.
  Future<User?> signUpWithEmail(String email, String password, String name, String role) async {
    try {
      // Step 1: Create the user in Firebase Authentication.
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Step 2: If the user is created successfully, save their details in a new Firestore document.
        // The document ID will be the user's unique ID (uid) from Firebase Auth.
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'role': role,
          'createdAt': Timestamp.now(), // Good practice to store a timestamp.
        });

        // Return the user object to confirm successful registration.
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase errors, like if the email is already in use.
      // This allows the UI to show a helpful message to the user.
      print('Firebase Auth Exception during sign-up: ${e.message}');
      return null;
    } catch (e) {
      // Catch any other unexpected errors.
      print('An unexpected error occurred during sign-up: $e');
      return null;
    }
  }

  /// Fetches the details of the currently authenticated user from Firestore.
  /// Returns an AppUser object if found, otherwise null.
  Future<AppUser?> getCurrentUserDetails() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      // No one is logged in.
      return null;
    }

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (userDoc.exists) {
        // Create an AppUser object from the Firestore data.
        return AppUser(
          uid: userDoc.get('uid'),
          email: userDoc.get('email'),
          name: userDoc.get('name'),
          role: userDoc.get('role'),
        );
      }
      return null;
    } catch (e) {
      print('Error fetching user details: $e');
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

  /// Signs the current user out.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

