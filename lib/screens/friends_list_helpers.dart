import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/friend_model.dart';
import '../repositories/friend_repositroy.dart';
import '../services/friends_list_page_service.dart';
import '../services/fetch_friend_event_gift_service.dart';
import '../services/friend_request_service.dart';

class FriendsListHelpers {
  final FriendRepository friendRepository;
  final FriendsListPageService friendsListPageService;
  final FetchFriendEventsAndGiftsService fetchFriendEventsAndGiftsService;

  FriendsListHelpers({
    required this.friendRepository,
    required this.friendsListPageService,
    required this.fetchFriendEventsAndGiftsService,
  });

  Future<List<Friend>> loadFriends(String currentUserId) async {
    return await friendRepository.fetchFriends(currentUserId);
  }

  Future<List<Map<String, dynamic>>> fetchFriendEvents(String friendId) async {
    return await friendsListPageService.fetchFriendEvents(friendId);
  }

  Future<void> syncEventsAndGifts(String friendId) async {
    await fetchFriendEventsAndGiftsService.syncEventsAndGifts(friendId);
  }

  Future<List<Friend>> filterFriends(
      String query,
      List<Friend> friends,
      FriendRepository friendRepository,
      ) async {
    if (query.isEmpty) {
      return friends;
    }

    List<Friend> filteredList = [];
    for (var friend in friends) {
      final userDetails = await friendRepository.fetchUserDetailsById(friend.friendId);

      if (userDetails != null) {
        final friendName = userDetails['name'].toLowerCase();
        if (friendName.contains(query.toLowerCase())) {
          filteredList.add(friend);
        }
      }
    }

    return filteredList;
  }

  Future<void> addFriendByPhoneNumber(
      BuildContext context,
      String currentUserId,
      FirebaseAuth auth,
      FriendRequestService friendRequestService,
      ) async {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Friend"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter friend's phone number"),
            keyboardType: TextInputType.phone,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final phoneNumber = controller.text.trim();
                Navigator.pop(context);

                try {
                  await friendRequestService.sendFriendRequest(
                    currentUserId: currentUserId,
                    phoneNumber: phoneNumber,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Friend request sent successfully.")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }
}
