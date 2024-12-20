import 'package:flutter/material.dart';
import '../notification/notification_listener.dart';
import 'profile_page.dart';
import 'event_list_page.dart';
import 'gift_list_page.dart';
import 'pledged_gift_page.dart';
import 'package:hedieaty_kevin_sherif_20p9405/screens/friends_list_page.dart';
import '../notification/notification_listener.dart' as custom_notification_listener;


// Updating friends table
import '../services/fetching_friends_service.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  const HomeScreen({super.key, required this.currentUserId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final FetchingFriendsService _fetchingFriendsService = FetchingFriendsService();
  late final custom_notification_listener.NotificationListener _notificationListener;

  Future<void> _fetchFriends() async {
    try {
      // Display a loading indicator while syncing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Syncing friends...")),
      );

      // Fetch and sync friends
      await _fetchingFriendsService.fetchAndSyncFriends();

      // Show a success message after sync
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Friends synced successfully!")),
      );
    } catch (e) {
      // Show an error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error syncing friends: $e")),
      );
    }
  }

  void initState() {
    super.initState();

    // Initialize the notification listener with the current user ID
    _notificationListener = custom_notification_listener.NotificationListener();
    _notificationListener.startListening(widget.currentUserId, context); // Pass the user ID and context
  }

  @override
  void dispose() {
    // Stop listening when the widget is disposed
    _notificationListener.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      FriendsListPage(currentUserId: widget.currentUserId),
      EventListPage(currentUserId: widget.currentUserId),
      GiftListPage(currentUserId: widget.currentUserId),
      PledgedGiftsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            // Fetch friends when Friends tab is selected
            await _fetchFriends();
          }
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
