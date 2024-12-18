import 'package:firebase_database/firebase_database.dart';

class FriendRequestService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Send a friend request
  Future<void> sendFriendRequest({
    required String currentUserId,
    required String phoneNumber,
  }) async {
    final userSnapshot = await _dbRef.child("users").orderByChild("phoneNumber").equalTo(phoneNumber).get();

    if (!userSnapshot.exists) throw Exception("User not found.");

    final Map<String, dynamic> users = Map<String, dynamic>.from(userSnapshot.value as Map);
    final targetUserId = users.keys.first;

    if (targetUserId == currentUserId) throw Exception("You cannot send a request to yourself.");

    await _dbRef.child("users/$currentUserId/outgoingRequests").child(targetUserId).set(true);
    await _dbRef.child("users/$targetUserId/incomingRequests").child(currentUserId).set(true);
  }

  // Fetch incoming friend requests
  Future<List<Map<String, String>>> getIncomingRequests(String userId) async {
    final snapshot = await _dbRef.child("users/$userId/incomingRequests").get();

    if (!snapshot.exists) return [];

    List<Map<String, String>> requests = [];
    final incomingRequests = Map<String, dynamic>.from(snapshot.value as Map);

    for (String requestUserId in incomingRequests.keys) {
      final userSnapshot = await _dbRef.child("users/$requestUserId").get();

      if (userSnapshot.exists) {
        final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
        requests.add({
          "uid": requestUserId,
          "name": userData["name"] ?? "Unknown",
          "email": userData["email"] ?? "Unknown",
          "phoneNumber": userData["phoneNumber"] ?? "Unknown",
        });
      }
    }
    return requests;
  }

  // Accept a friend request
  Future<void> acceptFriendRequest(String currentUserId, String senderId) async {
    // Add to friends list
    await _dbRef.child("users/$currentUserId/friends").child(senderId).set(true);
    await _dbRef.child("users/$senderId/friends").child(currentUserId).set(true);

    // Remove from incoming and outgoing requests
    await _dbRef.child("users/$currentUserId/incomingRequests").child(senderId).remove();
    await _dbRef.child("users/$senderId/outgoingRequests").child(currentUserId).remove();
  }

  // Decline a friend request
  Future<void> declineFriendRequest(String currentUserId, String senderId) async {
    // Remove the friend request
    await _dbRef.child("users/$currentUserId/incomingRequests").child(senderId).remove();
    await _dbRef.child("users/$senderId/outgoingRequests").child(currentUserId).remove();
  }
}
