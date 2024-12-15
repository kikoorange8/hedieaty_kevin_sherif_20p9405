import '../database/database_helper.dart';
import '../models/gift_model.dart';

class GiftRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Fetch gifts by user ID
  Future<List<Gift>> fetchGiftsForUser(String userId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT * FROM gifts WHERE eventId IN (SELECT id FROM events WHERE userId = ?)',
      [userId],
    );
    return result.map((map) => Gift.fromMap(map)).toList();
  }

  // Fetch gifts by status
  Future<List<Gift>> fetchGiftsByStatus({required String status, required String userId}) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT * FROM gifts WHERE status = ? AND eventId IN (SELECT id FROM events WHERE userId = ?)',
      [status, userId],
    );
    return result.map((map) => Gift.fromMap(map)).toList();
  }

  // Add a new gift
  Future<int> addGift(Gift gift) async {
    final db = await _dbHelper.database;
    return await db.insert('gifts', gift.toMap());
  }

  // Update an existing gift
  Future<int> updateGift(Gift gift) async {
    final db = await _dbHelper.database;
    return await db.update(
      'gifts',
      gift.toMap(),
      where: 'id = ?',
      whereArgs: [gift.id],
    );
  }

  // Delete a gift
  Future<int> deleteGift(int giftId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'gifts',
      where: 'id = ?',
      whereArgs: [giftId],
    );
  }
}
