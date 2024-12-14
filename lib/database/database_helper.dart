import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
      onCreate: (db, version) async {
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
      },
    );
  }
}
