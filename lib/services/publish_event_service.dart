import 'package:firebase_database/firebase_database.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';

import 'package:firebase_storage/firebase_storage.dart';
import '../models/gift_model.dart';
import '../repositories/gift_repository.dart';


class PublishEventService {
  final EventRepository _eventRepository = EventRepository();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GiftRepository _giftRepository = GiftRepository();

  Future<void> addGiftsForEvent(String userId, String eventId) async {
    try {
      // Fetch gifts associated with the user
      final List<Gift> gifts = await _giftRepository.fetchGiftsForUser(userId);

      // Filter gifts linked to the event
      final eventGifts = gifts.where((gift) => gift.eventId.toString() == eventId).toList();

      if (eventGifts.isEmpty) {
        print("No gifts found for event: $eventId");
        return;
      }

      for (final gift in eventGifts) {
        // Create gift data map (image is already a string in the database)
        final giftData = gift.toMap();

        // Upload gift data to Firebase Realtime Database
        try {
          await _dbRef.child("events/$userId/$eventId/gifts/${gift.id}").set(giftData);
          print("Gift '${gift.name}' uploaded successfully.");
        } catch (e) {
          print("Failed to upload gift: ${gift.name}, Error: $e");
        }
      }
    } catch (e) {
      print("Error in addGiftsForEvent: $e");
    }
  }

  Future<void> reassignGiftToEvent(
      String userId, String giftId, String oldEventId, String newEventId, bool isNewEventPublished) async {
    try {
      // Fetch the gift from local database
      final gift = await _giftRepository.getGiftById(giftId);

      if (gift == null) {
        print("Gift not found.");
        return;
      }

      // Remove the gift from the old event in Firebase
      await _dbRef.child("events/$userId/$oldEventId/gifts/$giftId").remove();
      print("Gift '$giftId' removed from event '$oldEventId' in Firebase.");

      if (isNewEventPublished) {
        // Add the gift to the new published event in Firebase
        await _dbRef.child("events/$userId/$newEventId/gifts/$giftId").set(gift.toMap());
        print("Gift '$giftId' added to event '$newEventId' in Firebase.");
      } else {
        // Update the eventId locally for the unpublished event
        final updatedGift = Gift(
          id: gift.id,
          name: gift.name,
          description: gift.description,
          category: gift.category,
          price: gift.price,
          status: gift.status,
          eventId: int.parse(newEventId),
          userId: gift.userId,
          image: gift.image,
        );
        await _giftRepository.updateGift(updatedGift);
        print("Gift '$giftId' updated locally to event '$newEventId'.");
      }
    } catch (e) {
      print("Error reassigning gift to event: $e");
    }
  }

  // Publish event to Firebase and update locally as published
  Future<void> publishEvent(Event event) async {
    try {
      print("Attempting to publish event...");
      print("Event ID: ${event.id}");
      print("Firebase Path: events/${event.id}");
      print("Event Data: ${event.toMap()}");

      // Debug: Print user ID from the event
      print("User ID in Event: ${event.userId}");

      // Push to Firebase
      await _dbRef.child("events/${event.userId}/${event.id}").set(event.toMap());
      print("Event '${event.name}' successfully published to Firebase.");

      // Mark event as published locally
      await _eventRepository.updateEvent(event.copyWith(published: 1));
      print("Event '${event.name}' marked as published locally.");
    } catch (e) {
      print("Error publishing event: $e");
      rethrow;
    }
  }




  // edit event if local edit local if global edit both local and firebase
  Future<void> editEvent(Event event) async {
    try {
      print("Attempting to edit event...");
      print("Event ID: ${event.id}");
      print("Firebase Path: events/${event.userId}/${event.id}");
      print("Event Data: ${event.toMap()}");
      print("Event Published Status: ${event.published}");

      if (event.published == 1) {
        // If published, update in Firebase and SQLite
        await _dbRef.child("events/${event.userId}/${event.id}").update(event.toMap());
        print("Event '${event.name}' updated in Firebase.");
      }

      // Update locally in SQLite
      await _eventRepository.updateEvent(event);
      print("Event '${event.name}' updated locally.");
    } catch (e) {
      print("Error editing event: $e");
      rethrow;
    }
  }

  // Save event locally to SQLite
  Future<void> saveEventLocally(Event event) async {
    try {
      await _eventRepository.addEvent(event);
      print("Event '${event.name}' saved locally.");
    } catch (e) {
      print("Error saving event locally: $e");
      rethrow;
    }
  }

  // Delete event (if published, delete from Firebase; otherwise delete locally)
  Future<void> deleteEvent(Event event) async {
    try {
      if (event.published == 1) {
        // Delete from Firebase
        await _dbRef.child("events/${event.id}").remove();
        print("Event '${event.name}' deleted from Firebase.");
      }

      // Delete locally
      await _eventRepository.deleteEvent(event.id);
      print("Event '${event.name}' deleted locally.");
    } catch (e) {
      print("Error deleting event: $e");
      rethrow;
    }
  }

  // Unpublish event: Remove from Firebase without changing local database
  Future<void> unpublishEvent(Event event) async {
    try {
      print("Unpublishing event: ${event.id}");

      // Remove from Firebase
      await _dbRef.child("events/${event.userId}/${event.id}").remove();
      print("Event '${event.name}' successfully removed from Firebase.");

      // Mark as unpublished locally
      await _eventRepository.updateEvent(event.copyWith(published: 0));
      print("Event '${event.name}' marked as unpublished locally.");
    } catch (e) {
      print("Error unpublishing event: $e");
      rethrow;
    }
  }


}
