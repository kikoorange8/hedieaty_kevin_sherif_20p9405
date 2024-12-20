import 'package:firebase_database/firebase_database.dart';
import '../database/database_helper.dart';
import 'package:flutter/material.dart';

class SyncEventAndGiftService {
  static final SyncEventAndGiftService _instance = SyncEventAndGiftService._internal();
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  factory SyncEventAndGiftService() {
    return _instance;
  }

  SyncEventAndGiftService._internal();

  // Centralized Listener for Events or Gifts
  void sync_event_or_gift_listener() {
    final eventsRef = _databaseRef.child('events');

    // Listen for changes in events
    eventsRef.onChildChanged.listen((userSnapshot) async {
      final userId = userSnapshot.snapshot.key;
      if (userId == null) return; // Skip null userId

      print("DEBUG: Detected Change in Events for User ID: $userId");

      final userEvents = userSnapshot.snapshot.value as Map<dynamic, dynamic>?;
      if (userEvents != null) {
        for (var eventId in userEvents.keys) {
          final eventData = userEvents[eventId] as Map<dynamic, dynamic>;

          // Process event changes
          await add_or_edit_event(eventId, eventData);

          // Handle changes within gifts
          if (eventData.containsKey('gifts')) {
            final gifts = eventData['gifts'] as Map<dynamic, dynamic>;
            for (var giftId in gifts.keys) {
              final giftData = gifts[giftId] as Map<dynamic, dynamic>;
              print("DEBUG: Detected Gift Change -> Gift ID: $giftId, Event ID: $eventId");
              await add_or_edit_gift(giftId, eventId, giftData);
            }
          }
        }
      }
    });

    // Listen for deletions in events
    eventsRef.onChildRemoved.listen((userSnapshot) async {
      final userId = userSnapshot.snapshot.key;
      if (userId == null) return; // Skip null userId

      print("DEBUG: Detected Event Deletion for User ID: $userId");

      final userEvents = userSnapshot.snapshot.value as Map<dynamic, dynamic>?;
      if (userEvents != null) {
        for (var eventId in userEvents.keys) {
          print("DEBUG: Processing Deletion for Event ID: $eventId");

          // Delete associated gifts
          print("DEBUG: Deleting Gifts for Event ID: $eventId");
          final giftsDeleted = await _dbHelper.delete(
            'gifts',
            where: 'eventId = ?',
            whereArgs: [eventId],
          );
          print("DEBUG: Deleted $giftsDeleted Gifts Associated with Event ID: $eventId");

          // Delete the event itself
          print("DEBUG: Deleting Event ID: $eventId");
          final rowsAffected = await _dbHelper.delete(
            'events',
            where: 'id = ?',
            whereArgs: [eventId],
          );

          if (rowsAffected > 0) {
            print("DEBUG: Successfully Deleted Event Locally -> Event ID: $eventId");
          } else {
            print("DEBUG: No Event Found Locally -> Event ID: $eventId");
          }
        }
      } else {
        print("DEBUG: No Events Found for Deletion for User ID: $userId");
      }
    });
  }

  Future<void> add_or_edit_event(String eventId, Map<dynamic, dynamic> eventData) async {
    try {
      final existingEvent = await _dbHelper.query(
        'SELECT * FROM events WHERE id = ?',
        [eventId],
      );

      if (existingEvent.isNotEmpty) {
        // If the event exists, update it
        await _dbHelper.update(
          'events',
          {
            'id': eventId,
            'name': eventData['name'],
            'description': eventData['description'],
            'date': eventData['date'],
            'location': eventData['location'],
            'userId': eventData['userId'],
            'published': eventData['published'],
          },
          where: 'id = ?',
          whereArgs: [eventId],
        );
        print("DEBUG: Event Updated Locally -> Event ID: $eventId");
      } else {
        // If the event does not exist, insert it
        await _dbHelper.insert(
          'events',
          {
            'id': eventId,
            'name': eventData['name'],
            'description': eventData['description'],
            'date': eventData['date'],
            'location': eventData['location'],
            'userId': eventData['userId'],
            'published': eventData['published'],
          },
        );
        print("DEBUG: Event Inserted Locally -> Event ID: $eventId");
      }
    } catch (e) {
      print("ERROR: Failed to Update or Insert Event in Local DB -> $e");
    }
  }

  Future<void> add_or_edit_gift(String giftId, String eventId, Map<dynamic, dynamic> giftData) async {
    try {
      final existingGift = await _dbHelper.query(
        'SELECT * FROM gifts WHERE id = ?',
        [giftId],
      );

      if (existingGift.isNotEmpty) {
        // If the gift exists, update it
        await _dbHelper.update(
          'gifts',
          {
            'id': giftId,
            'name': giftData['name'],
            'description': giftData['description'],
            'category': giftData['category'],
            'price': giftData['price'],
            'status': giftData['status'],
            'eventId': eventId,
            'userId': giftData['userId'],
          },
          where: 'id = ?',
          whereArgs: [giftId],
        );
        print("DEBUG: Gift Updated Locally -> Gift ID: $giftId");
      } else {
        // If the gift does not exist, insert it
        await _dbHelper.insert(
          'gifts',
          {
            'id': giftId,
            'name': giftData['name'],
            'description': giftData['description'],
            'category': giftData['category'],
            'price': giftData['price'],
            'status': giftData['status'],
            'eventId': eventId,
            'userId': giftData['userId'],
          },
        );
        print("DEBUG: Gift Inserted Locally -> Gift ID: $giftId");
      }
    } catch (e) {
      print("ERROR: Failed to Update or Insert Gift in Local DB -> $e");
    }
  }
}
