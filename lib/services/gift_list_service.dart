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
  Future<void> addGift(Gift gift) async {
    try {
      await _giftRepository.addGift(gift);
      print("Gift added to SQLite: \${gift.toMap()}");

      // If the gift is associated with a published event, add to Firebase
      if (gift.eventId != null) {
        final event = await _eventRepository.getEventById(gift.eventId.toString());
        if (event != null && event.published == 1) {
          await _addGiftToFirebase(event.userId, event.id, gift);
        }
      }
    } catch (e) {
      print("ERROR: Failed to add gift: $e");
      rethrow;
    }
  }

  // Update an existing gift
  Future<void> updateGift(Gift oldGift, Gift updatedGift) async {
    try {
      // Update the gift in SQLite
      await _giftRepository.updateGift(updatedGift);
      print("Gift updated in SQLite: \${updatedGift.toMap()}");

      // Handle Firebase updates for published events
      if (oldGift.eventId != updatedGift.eventId) {
        // If the old gift was part of a published event, delete it from Firebase
        if (oldGift.eventId != null) {
          final oldEvent = await _eventRepository.getEventById(oldGift.eventId.toString());
          if (oldEvent != null && oldEvent.published == 1) {
            await _deleteGiftFromFirebase(oldEvent.userId, oldEvent.id, oldGift.id.toString());
          }
        }

        // If the updated gift is part of a published event, add it to Firebase
        if (updatedGift.eventId != null) {
          final newEvent = await _eventRepository.getEventById(updatedGift.eventId.toString());
          if (newEvent != null && newEvent.published == 1) {
            await _addGiftToFirebase(newEvent.userId, newEvent.id, updatedGift);
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
      final gift = await _giftRepository.getGiftById(giftId);
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
