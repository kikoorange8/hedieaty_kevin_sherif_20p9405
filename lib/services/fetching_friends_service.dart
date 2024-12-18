import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../repositories/friend_repositroy.dart';
import '../repositories/user_repository.dart';
import '../models/friend_model.dart';
import '../models/user_model.dart';

class FetchingFriendsService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref(); // Firebase root reference
  final FriendRepository _friendRepository = FriendRepository(); // Friend repository
  final UserRepository _userRepository = UserRepository(); // User repository

  Future<void> fetchAndSyncFriends() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null || currentUserId.isEmpty) {
        print("Error: No logged-in user ID found.");
        return;
      }

      print("Starting fetchAndSyncFriends for user ID: $currentUserId");

      // Fetch friends data from Firebase
      final friendsSnapshot = await _dbRef.child("users/$currentUserId/friends").get();

      if (!friendsSnapshot.exists || friendsSnapshot.value == null) {
        print("No friends found for user $currentUserId.");
        return;
      }

      final friendsData = friendsSnapshot.value as Map<dynamic, dynamic>;
      print("Friends data for $currentUserId: $friendsData");

      for (String friendId in friendsData.keys) {
        print("Processing friend ID: $friendId");

        // Check if friend already exists in SQLite
        final existingFriend = await _friendRepository.fetchFriend(currentUserId, friendId);
        if (existingFriend == null) {
          // Add new friend to SQLite
          await _friendRepository.addFriend(
            Friend(userId: currentUserId, friendId: friendId),
          );
          print("Friend $friendId synced to SQLite.");
        } else {
          print("Friend $friendId already exists in SQLite.");
        }
      }

      print("Friends database synchronization completed.");
      // Fetch and save friends' user data
      await getFriendsData(currentUserId);
    } catch (e) {
      print("Error during fetchAndSyncFriends: $e");
    }
  }



  //  getFriendsData save to sql users
  Future<void> getFriendsData(String currentUserId) async {
    try {
      print("Starting getFriendsData for user ID: $currentUserId");

      // Step 1: Query the friends table in SQLite to get all friend IDs
      final friends = await _friendRepository.fetchFriends(currentUserId);
      if (friends.isEmpty) {
        print("No friends found in SQLite for user: $currentUserId");
        return;
      }

      print("Friends found in SQLite: ${friends.map((f) => f.friendId).toList()}");

      // Step 2: For each friend ID, fetch user data from Firebase
      for (var friend in friends) {
        final userSnapshot = await _dbRef.child("users").child(friend.friendId).get();

        if (userSnapshot.exists) {
          final userData = Map<String, dynamic>.from(userSnapshot.value as Map);

          // Step 3: Insert or update the user data into the users table
          await _userRepository.addOrUpdateUser(
            userId: friend.friendId,
            name: userData['name'] ?? 'Unknown',
            email: userData['email'] ?? 'Unknown',
            phoneNumber: userData['phoneNumber'] ?? 'Unknown',
            preferences: userData['preferences'] ?? '',
          );
          print("User data for ${friend.friendId} added/updated in SQLite.");
        } else {
          print("No user data found in Firebase for friend ID: ${friend.friendId}");
        }
      }

      print("Friends' user data successfully updated in the users table.");
    } catch (e) {
      print("Error during getFriendsData: $e");
    }
  }

}
