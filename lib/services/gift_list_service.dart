import '../repositories/gift_repository.dart';
import '../repositories/event_repository.dart';
import '../models/gift_model.dart';
import '../models/event_model.dart';

class GiftListService {
  final GiftRepository _giftRepository = GiftRepository();
  final EventRepository _eventRepository = EventRepository();

  // Fetch all gifts for the user
  Future<List<Gift>> getAllGifts(String userId) async {
    final gifts = await _giftRepository.fetchGiftsForUser(userId);
    print("DEBUG: Fetched Gifts: ${gifts.map((gift) => gift.toMap()).toList()}");
    return gifts;
  }

  // Fetch gifts with optional search query
  Future<List<Gift>> fetchGifts(String userId, String searchQuery) async {
    final allGifts = await _giftRepository.fetchGiftsForUser(userId);

    if (searchQuery.isNotEmpty) {
      return allGifts
          .where((gift) => gift.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    return allGifts;
  }

  // Fetch unassigned gifts (those not associated with any event)
  Future<List<Gift>> getUnassignedGifts(String userId) async {
    return await _giftRepository.fetchUnassignedGifts(userId);
  }

  // Fetch event IDs and names for the user
  Future<List<Event>> fetchEvents(String userId) async {
    return await _eventRepository.fetchEventsForUser(userId);
  }

  // Add a new gift
  Future<void> addGift(Gift gift) async {
    try {
      await _giftRepository.addGift(gift);
    } catch (e) {
      print("ERROR: Failed to add gift: $e");
      rethrow;
    }
  }

  // Update an existing gift
  Future<void> updateGift(Gift gift) async {
    await _giftRepository.updateGift(gift);
  }

  // Delete a gift
  Future<void> deleteGift(int giftId) async {
    await _giftRepository.deleteGift(giftId);
  }

  // Assign a gift to an event
  Future<void> assignGiftToEvent(int giftId, int eventId) async {
    await _giftRepository.assignGiftToEvent(giftId, eventId);
  }
}
