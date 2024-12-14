import 'package:flutter/material.dart';
import '../repositories/friend_repositroy.dart';
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
  final int _currentUserId = 1; // Simulated logged-in user ID
  List<Map<String, dynamic>> _friendsWithEvents = [];
  int _currentIndex = 0; // Keeps track of the selected tab

  @override
  void initState() {
    super.initState();
    _addSampleFriends();
    _fetchFriendsWithEvents();
  }

  Future<void> _addSampleFriends() async {
    // Add Friend 1 (No upcoming events)
    await _friendRepository.addFriend(Friend(
      userId: _currentUserId,
      friendId: 2,
      friendName: 'Alice',
      friendProfilePicture: '', // Add an asset or network path
      hasUpcomingEvents: true,
    ));

    // Add Friend 2 (No upcoming events)
    await _friendRepository.addFriend(Friend(
      userId: _currentUserId,
      friendId: 3,
      friendName: 'Bob',
      friendProfilePicture: '', // Add an asset or network path
      hasUpcomingEvents: false,
    ));
  }

  Future<void> _fetchFriendsWithEvents() async {
    // Fetch all friends for the current user
    final friends = await _friendRepository.fetchFriends(_currentUserId);

    // Add events to the friends' data
    final List<Map<String, dynamic>> friendsWithEvents = [];
    for (final friend in friends) {
      friendsWithEvents.add({
        'friend': friend,
        'events': friend.hasUpcomingEvents
            ? <String>['Event 1: Birthday'] // Explicit cast
            : <String>[], // Explicit cast
      });
    }

    setState(() {
      _friendsWithEvents = friendsWithEvents;
    });
  }

  final List<Widget> _pages = [
    // Pages for each tab
    const Center(child: Text('Friends List')), // Placeholder for Home tab
    EventListPage(),
    GiftListPage(),
    PledgedGiftPage(),
    ProfilePage(),
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
                                : 'assets/default_profile.png', // Fallback to a default profile image
                          ),
                        ),
                        title: Text(friend.friendName),
                        subtitle: Text(
                          events.isEmpty
                              ? 'No Upcoming Events'
                              : events.join('\n'), // Properly joins event strings
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          print('Tapped on ${friend.friendName}');
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
