import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class FetchFriendEventsAndGiftsService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> syncEventsAndGifts(String friendId) async {
    try {
      final db = await _dbHelper.database;

      // Fetch events for the friend
      print("Fetching events for Friend ID: $friendId");
      final eventsSnapshot = await _dbRef.child('events/$friendId').get();

      if (eventsSnapshot.exists) {
        final eventsData = Map<String, dynamic>.from(eventsSnapshot.value as Map);

        // Track existing event IDs in SQLite
        final existingEventIds = (await db.query(
          'events',
          columns: ['id'],
          where: 'userId = ?',
          whereArgs: [friendId],
        )).map((row) => row['id'] as String).toSet();

        final fetchedEventIds = <String>{}; // Track fetched event IDs

        for (var eventId in eventsData.keys) {
          final event = Map<String, dynamic>.from(eventsData[eventId]);

          // Add eventId to the event data
          event['id'] = eventId;
          event['userId'] = friendId;

          print("Event Data for ID $eventId: $event");

          // Save event to SQLite
          await _saveEvent(event);
          fetchedEventIds.add(eventId); // Add to fetched event IDs

          // Process gifts for the event
          if (event.containsKey('gifts') && event['gifts'] != null) {
            final giftsData = Map<String, dynamic>.from(event['gifts']);

            // Track existing gift IDs in SQLite
            final existingGiftIds = (await db.query(
              'gifts',
              columns: ['id'],
              where: 'eventId = ?',
              whereArgs: [eventId],
            )).map((row) => row['id'] as String).toSet();

            final fetchedGiftIds = <String>{}; // Track fetched gift IDs

            for (var giftId in giftsData.keys) {
              final gift = Map<String, dynamic>.from(giftsData[giftId]);

              // Add giftId and eventId to the gift data
              gift['id'] = giftId;
              gift['eventId'] = eventId;
              gift['userId'] = friendId;

              print("Gift Data for ID $giftId: $gift");

              // Save the gift to SQLite
              await _saveGift(gift);
              fetchedGiftIds.add(giftId); // Add to fetched gift IDs
            }

            // Delete gifts missing in Firebase
            final deletedGifts = existingGiftIds.difference(fetchedGiftIds);
            for (var deletedGiftId in deletedGifts) {
              await db.delete(
                'gifts',
                where: 'id = ?',
                whereArgs: [deletedGiftId],
              );
              print("Deleted gift ID $deletedGiftId from SQLite.");
            }
          }
        }

        // Delete events missing in Firebase
        final deletedEvents = existingEventIds.difference(fetchedEventIds);
        for (var deletedEventId in deletedEvents) {
          // Fetch event from SQLite to confirm its userId matches Firebase
          final localEvent = await db.query(
            'events',
            where: 'id = ?',
            whereArgs: [deletedEventId],
          );

          if (localEvent.isNotEmpty) {
            final localUserId = localEvent.first['userId'];

            // Check if the event still exists in Firebase under the correct friendId
            final eventInFirebase = await _dbRef.child('events/$localUserId/$deletedEventId').get();

            if (!eventInFirebase.exists) {
              // Delete gifts for the event
              await db.delete(
                'gifts',
                where: 'eventId = ?',
                whereArgs: [deletedEventId],
              );
              print("Deleted all gifts for Event ID $deletedEventId.");

              // Delete the event
              await db.delete(
                'events',
                where: 'id = ?',
                whereArgs: [deletedEventId],
              );
              print("Deleted event ID $deletedEventId from SQLite.");
            }
          }
        }

        // If the friend's ID does not exist in Firebase, delete all their events and gifts
        if (eventsData.isEmpty) {
          await db.delete(
            'events',
            where: 'userId = ?',
            whereArgs: [friendId],
          );
          print("Deleted all events for Friend ID $friendId from SQLite.");

          await db.delete(
            'gifts',
            where: 'userId = ?',
            whereArgs: [friendId],
          );
          print("Deleted all gifts for Friend ID $friendId from SQLite.");
        }

        print("Events and gifts synced successfully for Friend ID: $friendId.");
      } else {
        print("No events found for Friend ID: $friendId. Deleting associated records from SQLite.");

        // Delete all events and gifts for the friend
        await db.delete(
          'events',
          where: 'userId = ?',
          whereArgs: [friendId],
        );
        print("Deleted all events for Friend ID $friendId from SQLite.");

        await db.delete(
          'gifts',
          where: 'userId = ?',
          whereArgs: [friendId],
        );
        print("Deleted all gifts for Friend ID $friendId from SQLite.");
      }
    } catch (e) {
      print("Error syncing events and gifts for Friend ID $friendId: $e");
    }
  }

  // Save event to SQLite
  Future<void> _saveEvent(Map<String, dynamic> event) async {
    final db = await _dbHelper.database;

    try {
      print("Saving Event: ID = ${event['id']}, Name = ${event['name']}, UserID = ${event['userId']}");
      await db.insert(
        'events',
        {
          'id': event['id']?.toString() ?? '', // Ensure ID is a string
          'name': event['name'] ?? 'Unnamed Event',
          'date': event['date'] ?? '',
          'location': event['location'] ?? '',
          'description': event['description'] ?? '',
          'published': event['published'] is int ? event['published'] : int.tryParse(event['published']?.toString() ?? '0'),
          'userId': event['userId']?.toString() ?? '',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Event saved successfully: ID = ${event['id']}");
    } catch (e) {
      print("Error saving event: $e");
    }
  }

  // Save gift to SQLite
  Future<void> _saveGift(Map<String, dynamic> gift) async {
    final db = await _dbHelper.database;

    try {
      print("Saving Gift: ID = ${gift['id']}, Name = ${gift['name']}, EventID = ${gift['eventId']}, UserID = ${gift['userId']}");
      await db.insert(
        'gifts',
        {
          'id': gift['id']?.toString() ?? '', // Ensure ID is a string
          'name': gift['name'] ?? 'Unnamed Gift',
          'description': gift['description'] ?? '',
          'category': gift['category'] ?? '',
          'price': gift['price'] is int ? gift['price'] : int.tryParse(gift['price']?.toString() ?? '0'),
          'status': gift['status'] ?? 'Available',
          'eventId': gift['eventId']?.toString() ?? '',
          'userId': gift['userId']?.toString() ?? '',
          'image': gift['image'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Gift saved successfully: ID = ${gift['id']}");
    } catch (e) {
      print("Error saving gift: $e");
    }
  }
}
