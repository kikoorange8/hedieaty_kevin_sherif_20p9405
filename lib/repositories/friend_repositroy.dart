import 'package:sqflite/sqflite.dart';

import '../models/friend_model.dart';
import '../database/database_helper.dart';

class FriendRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Add a new friend
  Future<int> addFriend(Friend friend) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'friends',
      friend.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch a specific friend
  Future<Friend?> fetchFriend(String userId, String friendId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'friends',
      where: 'userId = ? AND friendId = ?',
      whereArgs: [userId, friendId],
    );

    if (result.isNotEmpty) {
      return Friend.fromMap(result.first);
    }
    return null;
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

  // Fetch all friends for a user
  Future<List<Friend>> fetchFriends(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'friends',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return maps.map((map) => Friend.fromMap(map)).toList();
  }
  Future<Map<String, dynamic>?> fetchUserDetailsById(String userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return result.first; // Return the first matching user
    }
    return null; // Return null if user not found
  }


  // Remove a friend
  Future<int> removeFriend(String userId, String friendId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'friends',
      where: 'userId = ? AND friendId = ?',
      whereArgs: [userId, friendId],
    );
  }
}
