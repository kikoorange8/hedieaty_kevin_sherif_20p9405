import 'package:firebase_database/firebase_database.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';

class PublishEventService {
  final EventRepository _eventRepository = EventRepository();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

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
