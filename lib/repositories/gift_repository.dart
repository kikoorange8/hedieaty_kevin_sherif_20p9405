import '../database/database_helper.dart';
import '../models/gift_model.dart';

class GiftRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Fetch gifts for the user (all gifts, not filtered by eventId)
  Future<List<Gift>> fetchGiftsForUser(String userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'gifts',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.map((map) => Gift.fromMap(map)).toList();
  }

  // Fetch unassigned gifts (eventId is null)
  Future<List<Gift>> fetchUnassignedGifts(String userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'gifts',
      where: 'userId = ? AND eventId IS NULL',
      whereArgs: [userId],
    );
    return result.map((map) => Gift.fromMap(map)).toList();
  }

  // Fetch gifts by status
  Future<List<Gift>> fetchGiftsByStatus({required String status, required String userId}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'gifts',
      where: 'status = ? AND userId = ?',
      whereArgs: [status, userId],
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

  // Assign a gift to an event
  Future<int> assignGiftToEvent(int giftId, int eventId) async {
    final db = await _dbHelper.database;
    return await db.update(
      'gifts',
      {'eventId': eventId},
      where: 'id = ?',
      whereArgs: [giftId],
    );
  }
}
