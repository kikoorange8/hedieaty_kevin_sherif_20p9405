import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';

class SignUpService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      // Step 1: Create user with Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final userId = firebaseUser.uid;

        // Step 2: Initialize user data in Firebase Realtime Database
        await _dbRef.child("users").child(userId).set({
          "name": name,
          "email": email,
          "phoneNumber": phoneNumber,
          "incomingRequests": {}, // Empty map for incoming requests
          "outgoingRequests": {}, // Empty map for outgoing requests
          "friends": {} // Empty map for friends
        });

        // Step 3: Save user data in SQLite (local database)
        final db = await _dbHelper.database;
        await db.insert(
          'users',
          {
            'id': userId,
            'name': name,
            'email': email,
            'phoneNumber': phoneNumber,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Step 4: Set default profile image in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_$userId', 'lib/assets/default_profile.png');

        print("User signed up and initialized successfully.");
        return true; // Sign-up was successful
      }
    } catch (e) {
      print("Sign-up failed: $e");
    }
    return false;
  }
}
