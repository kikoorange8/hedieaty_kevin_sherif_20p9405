import 'package:firebase_auth/firebase_auth.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart' as local_user; // Alias to avoid conflict

class SignUpService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      // 1. Register user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // 2. Prepare user data for local SQLite using alias
        final localUser = local_user.UserModel(
          id: firebaseUser.uid, // Use Firebase UID
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          preferences: '', // Empty for now
        );

        // 3. Save user to local SQLite
        await _dbHelper.addUser(localUser);

        // 4. Optionally, save user data to Firebase Realtime Database
        await firebaseUser.updateDisplayName(name);
        return true;
      }
      return false;
    } catch (e) {
      print("Signup failed: $e");
      return false;
    }
  }
}
