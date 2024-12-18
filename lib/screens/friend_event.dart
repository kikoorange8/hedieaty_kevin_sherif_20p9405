import 'package:flutter/material.dart';
import '../repositories/friend_repositroy.dart';
import '../models/friend_model.dart';

class FriendEventPage extends StatefulWidget {
  final String currentUserId;

  const FriendEventPage({super.key, required this.currentUserId});

  @override
  State<FriendEventPage> createState() => _FriendEventPageState();
}
class _FriendEventPageState extends State<FriendEventPage> {
  final FriendRepository _friendRepository = FriendRepository();
  List<Map<String, dynamic>> _friendsWithDetails = []; // Store friends with details
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriendsFromDatabase();
  }

  // Load friends and fetch their details from the 'users' table
  Future<void> _loadFriendsFromDatabase() async {
    try {
      final friends = await _friendRepository.fetchFriends(widget.currentUserId);
      List<Map<String, dynamic>> friendsDetails = [];

      for (var friend in friends) {
        final userDetails =
        await _friendRepository.fetchUserDetailsById(friend.friendId);

        if (userDetails != null) {
          friendsDetails.add({
            'friendId': friend.friendId,
            'name': userDetails['name'] ?? 'Unknown',
            'phoneNumber': userDetails['phoneNumber'] ?? 'Unknown',
            'email': userDetails['email'] ?? 'Unknown',
          });
        } else {
          friendsDetails.add({
            'friendId': friend.friendId,
            'name': 'Unknown',
            'phoneNumber': 'Unknown',
            'email': 'Unknown',
          });
        }
      }

      setState(() {
        _friendsWithDetails = friendsDetails;
      });
    } catch (e) {
      print("Error loading friends: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load friends.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends List"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _friendsWithDetails.isEmpty
          ? const Center(child: Text("No friends found."))
          : ListView.builder(
        itemCount: _friendsWithDetails.length,
        itemBuilder: (context, index) {
          final friend = _friendsWithDetails[index];
          return ListTile(
            title: Text("Name: ${friend['name']}"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Phone: ${friend['phoneNumber']}"),
                Text("Email: ${friend['email']}"),
              ],
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "Selected Friend: ${friend['name']} - ${friend['phoneNumber']}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
