import '../database/database_helper.dart';
import '../models/event_model.dart';

class EventRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Fetch events for a specific user
  Future<List<Event>> fetchEventsForUser(int userId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'events',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.map((map) => Event.fromMap(map)).toList();
  }

  // Add a new event
  Future<int> addEvent(Event event) async {
    final db = await _dbHelper.database;
    return await db.insert('events', event.toMap());
  }

  Future<int> updateEvent(Event event) async {
    final db = await _dbHelper.database;
    return await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<int> deleteEvent(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
