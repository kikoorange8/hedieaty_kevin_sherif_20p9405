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
      version: 6, // Increment this version number
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
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      category TEXT,
      price REAL NOT NULL,
      status TEXT NOT NULL, -- "Available" or "Pledged"
      eventId INTEGER, -- Nullable, associated with an event
      userId TEXT NOT NULL, -- User ID who created the gift
      image TEXT -- Base64-encoded image string
    )
    ''');
  }

  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }


  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("Upgrading database from version $oldVersion to $newVersion...");

    if (oldVersion < 6) { // Increment database version to 4
      await db.execute('ALTER TABLE gifts ADD COLUMN userId TEXT NOT NULL DEFAULT ""');
      print("Added 'userId' column to 'gifts' table.");
    }
  }

  // Query method
  Future<List<Map<String, dynamic>>> query(String sql, [List<Object?>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  // Update method
  Future<int> update(String table, Map<String, dynamic> values,
      {String? where, List<Object?>? whereArgs}) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  // Insert method
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values);
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
