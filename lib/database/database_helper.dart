import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  DatabaseHelper._privateConstructor();

  static Database? _database;

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
      version: 3, // Incremented version to trigger the upgrade
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hedieaty.db'); // Use the correct database name
    await deleteDatabase(path);
    print("Database deleted: $path");
  }

  Future<void> _onCreate(Database db, int version) async {
    print("Creating tables...");

    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        preferences TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE friends (
        userId TEXT NOT NULL,
        friendId TEXT NOT NULL,
        friendName TEXT NOT NULL,
        friendProfilePicture TEXT,
        hasUpcomingEvents INTEGER NOT NULL,
        PRIMARY KEY (userId, friendId)
      )
    ''');

    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        location TEXT,
        description TEXT,
        userId TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

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
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("Upgrading database from version $oldVersion to $newVersion...");

    if (oldVersion < 3) {
      // Add the phoneNumber column to the users table
      await db.execute('ALTER TABLE users ADD COLUMN phoneNumber TEXT DEFAULT ""');
      print("Added 'phoneNumber' column to 'users' table.");
    }
  }

  Future<int> addUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }
}
