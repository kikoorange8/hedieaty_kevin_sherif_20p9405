import '../database/database_helper.dart';
import '../models/friend_model.dart';

class FriendRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Friend>> fetchFriends(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'friends',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    // Return a list of Friend objects
    return maps.map((map) => Friend.fromMap(map)).toList();
  }

  // Add a new friend
  Future<int> addFriend(Friend friend) async {
    final db = await _dbHelper.database;
    return await db.insert('friends', friend.toMap());
  }

  // Delete a friend
  Future<int> deleteFriend(String friendId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'friends',
      where: 'friendId = ?',
      whereArgs: [friendId],
    );
  }
}
