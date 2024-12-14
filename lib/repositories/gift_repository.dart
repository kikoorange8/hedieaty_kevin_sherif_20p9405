import '../database/database_helper.dart';
import '../models/gift_model.dart';

class GiftRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> addGift(Gift gift) async {
    final db = await _dbHelper.database;
    return await db.insert('gifts', gift.toMap());
  }

  Future<List<Gift>> fetchGiftsForEvent(int eventId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gifts',
      where: 'eventId = ?',
      whereArgs: [eventId],
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
