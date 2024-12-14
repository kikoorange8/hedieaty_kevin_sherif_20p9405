import '../database/database_helper.dart';
import '../models/friend_model.dart';

class FriendRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Add a new friend
  Future<int> addFriend(Friend friend) async {
  final db = await _dbHelper.database;

  // Check if the friend already exists
  final existingFriend = await db.query(
    'friends',
    where: 'userId = ? AND friendId = ?',
    whereArgs: [friend.userId, friend.friendId],
  );

  if (existingFriend.isNotEmpty) {
    throw Exception('Friend already exists');
  }

  return await db.insert('friends', friend.toMap());
  }


  // Fetch all friends for a specific user
  Future<List<Friend>> fetchFriends(int userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'friends',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => Friend.fromMap(map)).toList();
  }

  // Delete a friend
  Future<int> deleteFriend(int userId, int friendId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'friends',
      where: 'userId = ? AND friendId = ?',
      whereArgs: [userId, friendId],
    );
  }
}
