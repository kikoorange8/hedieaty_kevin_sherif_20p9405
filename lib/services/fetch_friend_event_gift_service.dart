import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';



class FetchFriendEventsAndGiftsService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> syncEventsAndGifts(String currentUserId) async {
    try {
      final db = await _dbHelper.database;

      // Fetch friends from Firebase
      final friendsSnapshot = await _dbRef.child('users/$currentUserId/friends').get();

      if (friendsSnapshot.exists) {
        final friendsData = Map<String, dynamic>.from(friendsSnapshot.value as Map);

        for (var friendId in friendsData.keys) {
          // Fetch events for each friend
          final eventsSnapshot = await _dbRef.child('events/$friendId').get();

          if (eventsSnapshot.exists) {
            final eventsData = Map<String, dynamic>.from(eventsSnapshot.value as Map);

            for (var eventId in eventsData.keys) {
              final event = Map<String, dynamic>.from(eventsData[eventId]);

              // Save event to SQLite
              await _saveEvent(event, friendId);

              // Check if the event has gifts
              if (event.containsKey('gifts') && event['gifts'] != null) {
                final giftsData = Map<String, dynamic>.from(event['gifts']);
                for (var giftId in giftsData.keys) {
                  final gift = Map<String, dynamic>.from(giftsData[giftId]);
                  await _saveGift(gift);
                }
              }
            }
          } else {
            print("No events found for Friend ID: $friendId.");
          }
        }

        print("Events and gifts synced successfully.");
      } else {
        print("No friends found for user $currentUserId.");
      }
    } catch (e) {
      print("Error syncing events and gifts: $e");
    }
  }

  // Save event to SQLite
  Future<void> _saveEvent(Map<String, dynamic> event, String friendId) async {
    final db = await _dbHelper.database;

    try {
      print("Saving Event: ${event['id']}, Name: ${event['name']}");
      await db.insert(
        'events',
        {
          'id': event['id'], // Unique identifier for the event
          'name': event['name'] ?? 'Unnamed Event',
          'date': event['date'] ?? '',
          'location': event['location'] ?? '',
          'description': event['description'] ?? '',
          'published': event['published'] ?? 0,
          'userId': event['userId'] ?? '',
        },
        conflictAlgorithm: ConflictAlgorithm.replace, // Replace if the event ID already exists
      );
      print("Event saved successfully: ${event['id']}");
    } catch (e) {
      print("Error saving event: $e");
    }
  }



  // Save gift to SQLite
  Future<void> _saveGift(Map<String, dynamic> gift) async {
    final db = await _dbHelper.database;

    try {
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
          'image': gift['image'], // Save Base64-encoded string
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("Error saving gift: $e");
    }
  }
}
