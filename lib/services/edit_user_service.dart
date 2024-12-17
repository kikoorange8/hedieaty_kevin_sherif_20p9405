import 'package:firebase_database/firebase_database.dart';
import '../database/database_helper.dart';

class EditUserService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Update user field in Firebase and SQLite
  Future<void> updateField(String userId, String field, String newValue) async {
    try {
      // Update Firebase
      await _dbRef.child("users").child(userId).update({field: newValue});

      // Update SQLite
      final db = await _dbHelper.database;
      await db.update(
        'users',
        {field: newValue},
        where: 'id = ?',
        whereArgs: [userId],
      );

      print("$field updated successfully");
    } catch (e) {
      print("Error updating $field: $e");
    }
  }
}
