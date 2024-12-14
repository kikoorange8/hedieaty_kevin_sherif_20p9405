import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hedieaty.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create friends table
    await db.execute('''
      CREATE TABLE friends (
        userId INTEGER NOT NULL,
        friendId INTEGER NOT NULL,
        friendName TEXT NOT NULL,
        friendProfilePicture TEXT,
        hasUpcomingEvents INTEGER NOT NULL,
        PRIMARY KEY (userId, friendId)
      )
    ''');

    // Create events table
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        location TEXT,
        description TEXT,
        userId INTEGER NOT NULL
      )
    ''');
  }

  // Fetch events for a specific userId
  Future<List<Map<String, dynamic>>> fetchEventsForUser(int userId) async {
    final db = await database;
    return await db.query(
      'events',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}
