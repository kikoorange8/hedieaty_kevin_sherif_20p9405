import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/event_model.dart';

class EventRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Add a new event
  Future<int> addEvent(Event event) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'events',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all events for a specific user
  Future<List<Event>> fetchEventsForUser(int userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => Event.fromMap(map)).toList();
  }

  // Delete an event
  Future<int> deleteEvent(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
