import 'package:flutter/material.dart';
import '../repositories/friend_repositroy.dart';
import '../repositories/event_repository.dart';
import '../models/friend_model.dart';
import 'event_list_page.dart';
import 'gift_list_page.dart';
import 'pledged_gift_page.dart';
import 'profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FriendRepository _friendRepository = FriendRepository();
  final EventRepository _eventRepository = EventRepository();
  final int _currentUserId = 1; // Simulated logged-in user ID
  List<Map<String, dynamic>> _friendsWithEvents = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchFriendsWithEvents();
  }

  Future<void> _fetchFriendsWithEvents() async {
    print("Fetching friends with events...");
    final friends = await _friendRepository.fetchFriends(_currentUserId);

    final List<Map<String, dynamic>> friendsWithEvents = [];
    for (final friend in friends) {
      final events = await _eventRepository.fetchEventsForUser(friend.friendId);
      friendsWithEvents.add({
        'friend': friend,
        'events': events.map((e) => e.name).toList(),
      });
    }

    setState(() {
      _friendsWithEvents = friendsWithEvents;
    });
  }

  final List<Widget> _pages = [
    const Center(child: Text('Friends List')), // Placeholder for Friends tab
    EventListPage(), // Your Event List page
    GiftListPage(userId: 1, isCurrentUser: true), // My Gifts
    PledgedGiftPage(), // Pledged Gifts
    ProfilePage(), // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hedieaty'),
      ),
      body: _currentIndex == 0
          ? _friendsWithEvents.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _friendsWithEvents.length,
        itemBuilder: (context, index) {
          final friendData = _friendsWithEvents[index];
          final Friend friend = friendData['friend'];
          final List<String> events = friendData['events'] as List<String>;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(
                  friend.friendProfilePicture.isNotEmpty
                      ? friend.friendProfilePicture
                      : 'assets/default_profile.png', // Replace with your asset
                ),
              ),
              title: Text(friend.friendName),
              subtitle: Text(
                events.isEmpty
                    ? 'No Upcoming Events'
                    : events.join('\n'),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GiftListPage(
                      userId: friend.friendId, // Navigate with friend's ID
                    ),
                  ),
                );
              },
            ),
          );
        },
      )
          : _pages[_currentIndex],
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
