import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class FriendsListPageService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Fetch friends associated with the current user ID
  Future<List<Map<String, dynamic>>> fetchFriends(String userId) async {
    final db = await _dbHelper.database;

    return await db.query(
      'friends',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // Fetch events for a specific friend
  Future<List<Map<String, dynamic>>> fetchFriendEvents(String friendId) async {
    final db = await _dbHelper.database;

    return await db.query(
      'events',
      where: 'friendId = ?',
      whereArgs: [friendId],
    );
  }

  // Add a new friend using their phone number
  Future<void> addFriend(String userId, String phoneNumber) async {
    final db = await _dbHelper.database;

    // Check if the user exists based on the phone number
    final result = await db.query(
      'users',
      where: 'phoneNumber = ?',
      whereArgs: [phoneNumber],
    );

    if (result.isNotEmpty) {
      final friend = result.first;

      // Add friend to the friends table
      await db.insert(
        'friends',
        {
          'userId': userId,
          'friendId': friend['id'],
          'name': friend['name'],
        },
        conflictAlgorithm: ConflictAlgorithm.ignore, // Prevent duplicates
      );
    } else {
      throw Exception("User not found with phone number $phoneNumber");
    }
  }
}
