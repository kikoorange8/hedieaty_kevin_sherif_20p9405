import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/friend_request_service.dart';
import 'friend_event.dart';
import '../repositories/friend_repositroy.dart';
import '../models/friend_model.dart';

class FriendsListPage extends StatefulWidget {
  final String currentUserId;

  const FriendsListPage({super.key, required this.currentUserId});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  final FriendRequestService _friendRequestService = FriendRequestService();
  final FriendRepository _friendRepository = FriendRepository();
  final _auth = FirebaseAuth.instance;

  List<Friend> _friends = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  // Load friends from the SQLite database
  Future<void> _loadFriends() async {
    final friendsList = await _friendRepository.fetchFriends(widget.currentUserId);
    setState(() {
      _friends = friendsList;
    });
  }

  Future<void> _addFriendByPhoneNumber() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

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
                  await _friendRequestService.sendFriendRequest(
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

  Future<void> _showFriendRequests() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final requests = await _friendRequestService.getIncomingRequests(currentUserId);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Friend Requests"),
            content: requests.isEmpty
                ? const Text("No pending friend requests.")
                : SingleChildScrollView(
              child: Column(
                children: requests.map((request) {
                  return ListTile(
                    title: Text(request["name"] ?? "Unknown"),
                    subtitle: Text("${request["email"]} • ${request["phoneNumber"]}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            await _friendRequestService.acceptFriendRequest(
                              currentUserId,
                              request["uid"]!,
                            );
                            _loadFriends(); // Reload friends list
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            await _friendRequestService.declineFriendRequest(
                              currentUserId,
                              request["uid"]!,
                            );
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends List"),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: _addFriendByPhoneNumber,
            label: const Text("Add Friend"),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: _showFriendRequests,
            label: const Text("View Requests"),
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
      // Within the Friends Page body
      body: _friends.isEmpty
          ? const Center(child: Text("No friends yet."))
          : ListView.builder(
        itemCount: _friends.length, // Use dynamic count
        itemBuilder: (context, index) {
          final friend = _friends[index];
          return FutureBuilder<Map<String, dynamic>?>(
            future: _friendRepository.fetchUserDetailsById(friend.friendId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  title: Text("Loading..."),
                  subtitle: Text("Please wait"),
                );
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return ListTile(
                  title: Text("Friend ID: ${friend.friendId}"),
                  subtitle: const Text("User not found"),
                );
              }
              final userData = snapshot.data!;
              return ListTile(
                title: Text("Name: ${userData['name']}"),
                subtitle: Text("Phone: ${userData['phoneNumber']}"),
                leading: const Icon(Icons.person), // Optional: Add an icon
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Selected: ${userData['name']} (${userData['phoneNumber']})"),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
