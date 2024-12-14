import '../database/database_helper.dart';
import '../models/user_model.dart';

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Create a new user
  Future<int> addUser(User user) async {
    final db = await _dbHelper.database;
    return await db.insert('users', user.toMap());
  }

  // Read all users
  Future<List<User>> fetchUsers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Update a user
  Future<int> updateUser(User user) async {
    final db = await _dbHelper.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Delete a user
  Future<int> deleteUser(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
