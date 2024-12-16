import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user; // Return the signed-up user
    } catch (e) {
      print("Signup failed: $e");
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
