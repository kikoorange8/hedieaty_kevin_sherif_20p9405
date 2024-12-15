import 'package:flutter/material.dart';
import '../repositories/friend_repositroy.dart';
import '../models/friend_model.dart';

class FriendsListPage extends StatefulWidget {
  final String currentUserId;

  const FriendsListPage({super.key, required this.currentUserId});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  final FriendRepository _friendRepository = FriendRepository();
  List<Friend> _friends = [];

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
    final friends = await _friendRepository.fetchFriends(widget.currentUserId);
    setState(() {
      _friends = friends;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Friends")),
      body: _friends.isEmpty
          ? const Center(child: Text("No friends found."))
          : ListView.builder(
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          return ListTile(
            title: Text(friend.friendName),
            subtitle: Text(friend.hasUpcomingEvents ? "Has upcoming events" : "No upcoming events"),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(friend.friendProfilePicture),
            ),
            onTap: () {
              // Add navigation to friend's events or gift list here
            },
          );
        },
      ),
    );
  }
}
