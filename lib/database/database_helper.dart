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
      version: 4, // Increment this version number
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<int> updateUserProfileImage(String userId, String imageUrl) async {
    final db = await database;

    // Update the profile image URL in the SQLite database
    return await db.update(
      'users',
      {'profileImage': imageUrl},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
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
    );

    ''');


    await db.execute('''
    CREATE TABLE friends (
      userId TEXT NOT NULL,
      friendId TEXT NOT NULL,
      PRIMARY KEY (userId, friendId)
    )
    ''');


    await db.execute('''
      CREATE TABLE events (
       id TEXT PRIMARY KEY,
       name TEXT,
       date TEXT,
       location TEXT,
       description TEXT,
       userId TEXT,
       published INTEGER DEFAULT 0 -- 0 for not published, 1 for published
      )
    ''');

    await db.execute('''
      CREATE TABLE gifts (
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        category TEXT,
        price REAL,
        status TEXT, -- available, pledged
        eventId TEXT NULL, -- event association
        FOREIGN KEY (eventId) REFERENCES events(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("Upgrading database from version $oldVersion to $newVersion...");

    if (oldVersion < 4) { // Increment database version to 4
      await db.execute('ALTER TABLE users ADD COLUMN profileImage TEXT DEFAULT ""');
      print("Added 'profileImage' column to 'users' table.");
    }
  }



  Future<int> addUser(UserModel user) async {
    try {
      print("Inserting user into SQLite: ${user.toMap()}");
      final db = await database;
      final result = await db.insert('users', user.toMap());
      print("SQLite insert result: $result");
      return result;
    } catch (e) {
      print("SQLite error during addUser: $e");
      return -1; // Return -1 to indicate failure
    }
  }

}
