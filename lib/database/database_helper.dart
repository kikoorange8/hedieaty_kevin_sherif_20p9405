import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';



class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Private constructor
  DatabaseHelper._privateConstructor();

  // Database reference
  static Database? _database;

  // Getter for the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }



  // Initialize the database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath(); // Path to the databases directory
    final path = join(dbPath, 'hedieaty.db'); // Name of the database file

    return await openDatabase(
      path,
      version: 1, // Increment this version if schema changes
      onCreate: _onCreate,
    );
  }
  // Testing
  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hedieaty.db'); // Ensure the correct database name
    await deleteDatabase(path);
    print("Database deleted: $path");
  }

  // Create tables when the database is initialized
  Future<void> _onCreate(Database db, int version) async {
    print("Creating tables...");

    await db.execute('''
    CREATE TABLE users (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT NOT NULL,
      preferences TEXT
    )
    ''');

    print("Users table created.");

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
    print("Friends table created.");

    // Create events table
    await db.execute('''
    CREATE TABLE events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      date TEXT NOT NULL,
      location TEXT,
      description TEXT,
      userId INTEGER NOT NULL,
      FOREIGN KEY (userId) REFERENCES friends(friendId) ON DELETE CASCADE
    )
  ''');
    print("Events table created.");

    // Create gifts table
    await db.execute('''
    CREATE TABLE gifts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      category TEXT NOT NULL,
      price REAL NOT NULL,
      status TEXT NOT NULL,
      eventId INTEGER NOT NULL,
      FOREIGN KEY (eventId) REFERENCES events(id) ON DELETE CASCADE
    )
  ''');
    print("Gifts table created.");
  }
}