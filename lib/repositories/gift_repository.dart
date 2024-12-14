import '../database/database_helper.dart';
import '../models/gift_model.dart';

class GiftRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Fetch all gifts for a specific user
  Future<List<Gift>> fetchGiftsForUser(int userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gifts',
      where: 'eventId IN (SELECT id FROM events WHERE userId = ?)',
      whereArgs: [userId],
    );
    return maps.map((map) => Gift.fromMap(map)).toList();
  }

  // Fetch all gifts by status (e.g., "Pledged")
  Future<List<Gift>> fetchGiftsByStatus(String status) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gifts',
      where: 'status = ?',
      whereArgs: [status],
    );
    return maps.map((map) => Gift.fromMap(map)).toList();
  }

  // Update gift (e.g., pledge a gift)
  Future<int> updateGift(Gift gift) async {
    final db = await _dbHelper.database;
    return await db.update(
      'gifts',
      gift.toMap(),
      where: 'id = ?',
      whereArgs: [gift.id],
    );
  }
}
