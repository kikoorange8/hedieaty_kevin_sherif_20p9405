import 'package:firebase_database/firebase_database.dart';

class FriendRequestService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<Map<String, dynamic>?> checkUserExists(String input) async {
    final snapshot = await _dbRef.child("users").orderByChild("email").equalTo(input).get();

    if (!snapshot.exists) {
      final phoneSnapshot = await _dbRef.child("users").orderByChild("phoneNumber").equalTo(input).get();
      if (phoneSnapshot.exists) {
        return Map<String, dynamic>.from(phoneSnapshot.value as Map);
      }
      return null;
    }

    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  Future<void> sendFriendRequest({
    required String senderId,
    required String receiverId,
    required String senderUsername,
  }) async {
    await _dbRef.child("friend_requests/$receiverId/$senderId").set({
      "username": senderUsername,
      "status": "pending",
    });
  }

  Future<void> acceptFriendRequest({
    required String senderId,
    required String receiverId,
    required String senderUsername,
    required String receiverUsername,
  }) async {
    // Remove the request
    await _dbRef.child("friend_requests/$receiverId/$senderId").remove();

    // Add to Firebase friends table
    await _dbRef.child("friends/$receiverId/$senderId").set({"username": senderUsername});
    await _dbRef.child("friends/$senderId/$receiverId").set({"username": receiverUsername});
  }

  Future<void> denyFriendRequest({required String senderId, required String receiverId}) async {
    await _dbRef.child("friend_requests/$receiverId/$senderId").remove();
  }
}
