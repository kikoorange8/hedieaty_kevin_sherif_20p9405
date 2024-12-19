import '../database/database_helper.dart';
import '../models/event_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_database/firebase_database.dart';

class EventRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Event?> getEventById(String eventId) async {
    final db = await _dbHelper.database;
    final result = await db.query('events', where: 'id = ?', whereArgs: [eventId]);
    if (result.isNotEmpty) {
      return Event.fromMap(result.first);
    }
    return null;
  }


  // Fetch events for a specific user
  Future<List<Event>> fetchEventsForUser(String userId) async {
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

  // Update an existing event
  Future<int> updateEvent(Event event) async {
    final db = await _dbHelper.database;
    return await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<int> deleteEvent(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> countUpcomingEvents(String userId) async {
    final db = await _dbHelper.database;

    // Get the current date in ISO8601 format
    final currentDate = DateTime.now().toIso8601String();

    // Query to count events where userId matches and date is in the future
    final result = await db.rawQuery(
      '''
    SELECT COUNT(*) as count 
    FROM events 
    WHERE userId = ? AND date >= ?
    ''',
      [userId, currentDate],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }



  Future<void> publishEvent(Event event) async {
    final db = await _dbHelper.database;

    // Push event data to Firebase
    await FirebaseDatabase.instance.ref("events/${event.id}").set(event.toMap());

    // Update the local event as published
    await db.update(
      'events',
      {'published': 1},
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }



}
