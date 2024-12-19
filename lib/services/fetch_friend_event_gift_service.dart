import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class FetchFriendEventsAndGiftsService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Fetch events and gifts for all friends
  Future<void> fetchAndSyncFriendEvents(String currentUserId) async {
    try {
      final db = await _dbHelper.database;

      // Fetch friends from SQLite
      final friends = await db.query('friends', where: 'userId = ?', whereArgs: [currentUserId]);

      for (var friend in friends) {
        final friendId = friend['friendId'];

        // Fetch events from Firebase
        final eventsSnapshot = await _dbRef.child('events/$friendId').get();

        if (eventsSnapshot.exists) {
          final eventsData = Map<String, dynamic>.from(eventsSnapshot.value as Map);

          for (var eventId in eventsData.keys) {
            final event = eventsData[eventId];
            // Save event to SQLite
            await _saveEvent(event, friendId);

            // Save gifts for the event
            if (event['gifts'] != null) {
              final gifts = Map<String, dynamic>.from(event['gifts']);
              for (var giftId in gifts.keys) {
                final gift = gifts[giftId];
                await _saveGift(gift);
              }
            }
          }
        }
      }

      print("Events and gifts synced successfully.");
    } catch (e) {
      print("Error syncing events and gifts: $e");
    }
  }

  // Save event to SQLite
  Future<void> _saveEvent(Map<String, dynamic> event, String friendId) async {
    final db = await _dbHelper.database;

    await db.insert(
      'events',
      {
        'id': event['id'],
        'name': event['name'],
        'date': event['date'],
        'description': event['description'],
        'location': event['location'],
        'published': event['published'],
        'userId': event['userId'],
        'friendId': friendId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Save gift to SQLite
  Future<void> _saveGift(Map<String, dynamic> gift) async {
    final db = await _dbHelper.database;

    await db.insert(
      'gifts',
      {
        'id': gift['id'],
        'name': gift['name'],
        'description': gift['description'],
        'category': gift['category'],
        'price': gift['price'],
        'status': gift['status'],
        'eventId': gift['eventId'],
        'userId': gift['userId'],
        'image': gift['image'], // Save base64 string as-is
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
