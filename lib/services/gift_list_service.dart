import '../repositories/gift_repository.dart';
import '../repositories/event_repository.dart';
import '../models/gift_model.dart';
import '../models/event_model.dart';
import 'package:firebase_database/firebase_database.dart';

class GiftListService {
  final GiftRepository _giftRepository = GiftRepository();
  final EventRepository _eventRepository = EventRepository();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Fetch all gifts for the user
  Future<List<Gift>> getAllGifts(String userId) async {
    final gifts = await _giftRepository.fetchGiftsForUser(userId);
    print("DEBUG: Fetched Gifts: \${gifts.map((gift) => gift.toMap()).toList()}");
    return gifts;
  }

  // Add a new gift
  Future<void> addGift(Gift gift, {bool isPublished = false}) async {
    try {
      // Add the gift to SQLite
      await _giftRepository.addGift(gift);

      // If the event is published, upload the gift to Firebase
      if (isPublished) {
        final eventId = gift.eventId?.toString() ?? '';
        if (eventId.isNotEmpty) {
          await uploadGiftToFirebase(gift.userId, eventId, gift);
          print("Gift uploaded to Firebase for Event ID $eventId.");
        }
      }
    } catch (e) {
      print("ERROR: Failed to add gift: $e");
      rethrow;
    }
  }

  Future<void> uploadGiftToFirebase(String userId, String eventId, Gift gift) async {
    final DatabaseReference ref = FirebaseDatabase.instance.ref('events/$userId/$eventId/gifts/${gift.id}');
    try {
      await ref.set({
        'id': gift.id.toString(),
        'name': gift.name,
        'description': gift.description,
        'category': gift.category,
        'price': gift.price,
        'status': gift.status,
        'image': gift.image,
      });
      print("Gift uploaded to Firebase for Event ID $eventId.");
    } catch (e) {
      print("Error uploading gift to Firebase: $e");
      rethrow;
    }
  }


  // Update an existing gift
  Future<void> updateGift(Gift oldGift, Gift updatedGift) async {
    try {
      // Update the gift in SQLite
      await _giftRepository.updateGift(updatedGift);
      print("Gift updated in SQLite: ${updatedGift.toMap()}");

      // If event ID has changed, handle Firebase updates
      if (oldGift.eventId != updatedGift.eventId) {
        // Remove from the old event in Firebase if necessary
        if (oldGift.eventId != null && oldGift.eventId != 0) {
          final oldEvent = await _eventRepository.getEventById(oldGift.eventId.toString());
          if (oldEvent != null && oldEvent.published == 1) {
            await _deleteGiftFromFirebase(oldEvent.userId, oldEvent.id, oldGift.id.toString());
            print("Gift '${oldGift.id}' removed from event '${oldEvent.id}' in Firebase.");
          }
        }

        // Add to the new event in Firebase if necessary
        if (updatedGift.eventId != null && updatedGift.eventId != 0) {
          final newEvent = await _eventRepository.getEventById(updatedGift.eventId.toString());
          if (newEvent != null && newEvent.published == 1) {
            await _addGiftToFirebase(newEvent.userId, newEvent.id, updatedGift);
            print("Gift '${updatedGift.id}' added to event '${newEvent.id}' in Firebase.");
          }
        }
      }
    } catch (e) {
      print("ERROR: Failed to update gift: $e");
      rethrow;
    }
  }






  // Delete a gift
  Future<void> deleteGift(int giftId) async {
    try {
      final gift = await _giftRepository.getGiftById(giftId.toString());
      if (gift != null) {
        // If the gift is part of a published event, delete it from Firebase
        if (gift.eventId != null) {
          final event = await _eventRepository.getEventById(gift.eventId.toString());
          if (event != null && event.published == 1) {
            await _deleteGiftFromFirebase(event.userId, event.id, gift.id.toString());
          }
        }

        // Delete the gift from SQLite
        await _giftRepository.deleteGift(giftId);
        print("Gift deleted from SQLite: ID = $giftId");
      }
    } catch (e) {
      print("ERROR: Failed to delete gift: $e");
      rethrow;
    }
  }

  // Add a gift to Firebase
  Future<void> _addGiftToFirebase(String userId, String eventId, Gift gift) async {
    try {
      await _dbRef.child('events/$userId/$eventId/gifts/${gift.id}').set(gift.toMap());
      print("Gift added to Firebase: \${gift.toMap()}");
    } catch (e) {
      print("ERROR: Failed to add gift to Firebase: $e");
    }
  }

  // Delete a gift from Firebase
  Future<void> _deleteGiftFromFirebase(String userId, String eventId, String giftId) async {
    try {
      await _dbRef.child('events/$userId/$eventId/gifts/$giftId').remove();
      print("Gift deleted from Firebase: ID = $giftId");
    } catch (e) {
      print("ERROR: Failed to delete gift from Firebase: $e");
    }
  }
}
