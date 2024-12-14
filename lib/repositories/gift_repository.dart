import '../database/database_helper.dart';
import '../models/gift_model.dart';

class GiftRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Fetch gifts for a specific user or friend's events
  Future<List<Gift>> fetchGiftsForUser(int userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gifts',
      where: 'eventId IN (SELECT id FROM events WHERE userId = ?)',
      whereArgs: [userId],
    );
    return maps.map((map) => Gift.fromMap(map)).toList();
  }


  Future<int> updateGift(Gift gift) async {
    final db = await _dbHelper.database;
    return await db.update(
      'gifts',
      gift.toMap(),
      where: 'id = ?',
      whereArgs: [gift.id],
    );
  }

  Future<int> deleteGift(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'gifts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}