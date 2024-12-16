import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../database/database_helper.dart';
import '../models/friend_model.dart';
import '../repositories/friend_repositroy.dart';

import 'profile_page.dart';
import 'event_list_page.dart';
import 'gift_list_page.dart';
import 'pledged_gift_page.dart';
import 'friends_list_page.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  const HomeScreen({super.key, required this.currentUserId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FriendRepository _friendRepository = FriendRepository();

  @override
  void initState() {
    super.initState();
    _syncFriendsFromFirebase();
  }

  /// Fetch friends from Firebase and update local SQLite database
  Future<void> _syncFriendsFromFirebase() async {
    try {
      final snapshot = await _dbRef.child("friends/${widget.currentUserId}").get();
      if (snapshot.exists) {
        final Map<String, dynamic> friendsMap =
        Map<String, dynamic>.from(snapshot.value as Map);

        // Clear local friends table (optional: you can choose to update instead)
        //await _dbHelper.updateFriends();

        // Insert each friend into SQLite database
        for (var entry in friendsMap.entries) {
          final friend = Friend(
            userId: widget.currentUserId,
            friendId: entry.key,
            friendName: entry.value['friendName'] ?? '',
            friendProfilePicture: entry.value['profilePicture'] ?? '',
            hasUpcomingEvents: false, // Default value for now
          );
          await _friendRepository.addFriend(friend);
        }

        print("Friends synchronized successfully!");
      }
    } catch (e) {
      print("Error syncing friends: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      FriendsListPage(currentUserId: widget.currentUserId),
      EventListPage(currentUserId: widget.currentUserId),
      GiftListPage(userId: widget.currentUserId, isCurrentUser: true),
      PledgedGiftPage(currentUserId: widget.currentUserId),
      ProfilePage(userId: widget.currentUserId),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Gifts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake),
            label: 'Pledged',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
