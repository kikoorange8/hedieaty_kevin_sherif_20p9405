import 'package:flutter/material.dart';
import 'package:hedieaty_kevin_sherif_20p9405/repositories/friend_repositroy.dart';
import 'gift_list_page.dart';
import '../models/friend_model.dart';


class FriendsListPage extends StatefulWidget {
  final int currentUserId;

  const FriendsListPage({super.key, required this.currentUserId});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  final FriendRepository _friendRepository = FriendRepository();
  List<Map<String, dynamic>> _friendsWithEvents = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchFriendsWithEvents();
  }

  Future<void> _fetchFriendsWithEvents() async {
    final friends = await _friendRepository.fetchFriends(widget.currentUserId);
    setState(() {
      _friendsWithEvents = friends.map((friend) {
        return {
          'friend': friend,
          'events': friend.hasUpcomingEvents ? ["Event 1: Birthday"] : [],
        };
      }).toList();
    });
  }

  void _searchFriends(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _addFriendManually() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final phoneController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Friend'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty) {
                  await _friendRepository.addFriend(Friend(
                    userId: 1, // Replace with the current logged-in user ID
                    friendId: DateTime.now().millisecondsSinceEpoch,
                    friendName: nameController.text,
                    friendProfilePicture: '',
                    hasUpcomingEvents: false,
                  ));

                  await _fetchFriendsWithEvents();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Friend added successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields.')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredFriends = _friendsWithEvents.where((friendData) {
      final friend = friendData['friend'];
      return friend.friendName.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addFriendManually,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Friends',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _searchFriends,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredFriends.length,
              itemBuilder: (context, index) {
                final friendData = filteredFriends[index];
                final friend = friendData['friend'];
                return ListTile(
                  title: Text(friend.friendName),
                  subtitle: Text(friendData['events'].isEmpty
                      ? "No Upcoming Events"
                      : friendData['events'].join(", ")),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GiftListPage(
                          userId: friend.friendId,
                          isCurrentUser: false,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
