import 'package:flutter/material.dart';
import '../services/friend_request_service.dart';

class FriendsListPage extends StatefulWidget {
  final String currentUserId;

  const FriendsListPage({super.key, required this.currentUserId});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  final FriendRequestService _friendRequestService = FriendRequestService();

  void _showAddFriendDialog() {
    final TextEditingController _inputController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Friend"),
          content: TextField(
            controller: _inputController,
            decoration: const InputDecoration(labelText: "Email or Phone Number"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final input = _inputController.text.trim();
                final result = await _friendRequestService.checkUserExists(input);
                Navigator.pop(context);

                if (result != null) {
                  await _friendRequestService.sendFriendRequest(
                    senderId: widget.currentUserId,
                    receiverId: result['userId'],
                    senderUsername: "YourUsernameHere", // Replace with actual username
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Friend request sent!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User not found!")),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddFriendDialog,
          ),
        ],
      ),
      body: const Center(
        child: Text("Friends List Screen"),
      ),
    );
  }
}
