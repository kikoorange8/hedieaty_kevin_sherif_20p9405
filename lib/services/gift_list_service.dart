import '../repositories/gift_repository.dart';
import '../models/gift_model.dart';

class GiftListService {
  final GiftRepository _giftRepository = GiftRepository();

  // Fetch all gifts for the user
  Future<List<Gift>> getAllGifts(String userId) async {
    // Placeholder for Firebase integration if needed
    // Add Firebase fetch logic here if required in the future

    return await _giftRepository.fetchGiftsForUser(userId); // Fetch from SQLite
  }

  // Fetch gifts with optional search query
  Future<List<Gift>> fetchGifts(String userId, String searchQuery) async {
    // Fetch all gifts from SQLite
    final allGifts = await _giftRepository.fetchGiftsForUser(userId);

    // Placeholder for Firebase integration if needed
    // Add Firebase search logic here if required in the future

    if (searchQuery.isNotEmpty) {
      return allGifts
          .where((gift) => gift.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    return allGifts;
  }

  // Fetch unassigned gifts (those not associated with any event)
  Future<List<Gift>> getUnassignedGifts(String userId) async {
    // Placeholder for Firebase integration if needed
    // Add Firebase fetch logic for unassigned gifts here if required

    return await _giftRepository.fetchUnassignedGifts(userId); // Fetch from SQLite
  }

  // Add a new gift
  Future<void> addGift(Gift gift) async {
    // Placeholder for Firebase integration
    // Add Firebase logic to sync the new gift to the cloud if needed

    await _giftRepository.addGift(gift); // Save to SQLite
  }

  // Update an existing gift
  Future<void> updateGift(Gift gift) async {
    // Placeholder for Firebase integration
    // Add Firebase logic to sync updates to the cloud if needed

    await _giftRepository.updateGift(gift); // Update in SQLite
  }

  // Delete a gift
  Future<void> deleteGift(int giftId) async {
    // Placeholder for Firebase integration
    // Add Firebase logic to remove the gift from the cloud if needed

    await _giftRepository.deleteGift(giftId); // Remove from SQLite
  }

  // Assign a gift to an event
  Future<void> assignGiftToEvent(int giftId, int eventId) async {
    // Placeholder for Firebase integration
    // Add Firebase logic to sync the assignment to the cloud if needed

    await _giftRepository.assignGiftToEvent(giftId, eventId); // Update in SQLite
  }
}
