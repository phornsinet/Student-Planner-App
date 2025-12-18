import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Sign Up
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'This email is already registered. Try logging in.';
      } else if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is not valid.';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // 2. Sign In
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return "success";
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // 3. Password Reset
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      print("Reset Error: $e");
      rethrow;
    }
  }

  // 4. Sign Out (Only ONE version allowed)
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print("User signed out successfully");
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  // 5. Auth State Stream
  Stream<User?> get userStatus => _auth.authStateChanges();
}
