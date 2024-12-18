import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/user_model.dart';

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> addUser(UserModel user) async {
    return await _dbHelper.addUser(user);
  }

  Future<List<UserModel>> fetchUsers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return maps.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<UserModel?> fetchUserById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(UserModel user) async {
    final db = await _dbHelper.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Add or update user details
  Future<int> addOrUpdateUser({
    required String userId,
    required String name,
    required String email,
    required String phoneNumber,
    required String preferences,
  }) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'users',
      {
        'id': userId,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'preferences': preferences,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }




  // Check if a user exists in the local database
  Future<bool> isUserInLocalDatabase(String userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty; // Returns true if the user exists
  }

  // Add or update user details
  Future<void> addUserIfNotExists(Map<String, dynamic> userData) async {
    final db = await _dbHelper.database;

    // Check if user already exists
    final exists = await isUserInLocalDatabase(userData['id']);
    if (!exists) {
      await db.insert(
        'users',
        userData,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      print("User added to SQLite: ${userData['name']}");
    } else {
      print("User already exists in SQLite.");
    }
  }

}
