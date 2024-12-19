import '../database/database_helper.dart';
import '../models/gift_model.dart';

class GiftRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Fetch gifts for the user (all gifts, not filtered by eventId)
  Future<List<Gift>> fetchGiftsForUser(String userId) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'gifts',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return maps.map((map) {
      return Gift(
        id: map['id'] as int,
        name: map['name'] as String,
        description: map['description'] as String,
        category: map['category'] as String,
        price: map['price'] as double,
        status: map['status'] as String,
        eventId: map['eventId'] != null ? map['eventId'] as int : null, // Safeguard
        userId: map['userId'] as String,
        image: map['image'] as String?,
      );
    }).toList();
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

    final updateData = {
      'name': gift.name,
      'description': gift.description,
      'category': gift.category,
      'price': gift.price,
      'status': gift.status,
      'eventId': gift.eventId,
      'userId': gift.userId,
      'image': gift.image ?? "", // Ensure non-null value
    };

    print("DEBUG: Updating Gift in SQLite with data: $updateData");

    final result = await db.update(
      'gifts',
      updateData,
      where: 'id = ?',
      whereArgs: [gift.id],
    );

    print("DEBUG: Rows affected by update: $result");
    return result;
  }


  // Fetch a gift by its ID
  Future<Gift?> getGiftById(String giftId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'gifts',
      where: 'id = ?',
      whereArgs: [giftId],
    );

    if (result.isNotEmpty) {
      return Gift.fromMap(result.first);
    } else {
      return null; // Gift not found
    }
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
