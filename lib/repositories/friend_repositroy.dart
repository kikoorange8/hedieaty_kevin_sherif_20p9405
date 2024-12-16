import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/friend_model.dart';

class FriendRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Add a new friend
  Future<int> addFriend(Friend friend) async {
    final db = await _dbHelper.database;
    return await db.insert('friends', friend.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Fetch friends for a user
  Future<List<Friend>> fetchFriends(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'friends',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => Friend.fromMap(map)).toList();
  }

  // Delete a friend
  Future<int> deleteFriend(String userId, String friendId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'friends',
      where: 'userId = ? AND friendId = ?',
      whereArgs: [userId, friendId],
    );
  }
}
