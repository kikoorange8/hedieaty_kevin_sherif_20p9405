import 'package:flutter/material.dart';
import 'package:hedieaty_kevin_sherif_20p9405/models/event_model.dart';
import 'package:hedieaty_kevin_sherif_20p9405/screens/event_list_page.dart';
import 'package:hedieaty_kevin_sherif_20p9405/screens/gift_list_page.dart';
import 'package:hedieaty_kevin_sherif_20p9405/screens/pledged_gift_page.dart';
import 'package:hedieaty_kevin_sherif_20p9405/screens/profile_page.dart';
import '../repositories/friend_repositroy.dart';
import '../repositories/event_repository.dart';
import '../models/friend_model.dart';

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
  int _currentIndex = 0; // Current tab index

  @override
  void initState() {
    super.initState();
    _addSampleData();
    _fetchFriendsWithEvents();
  }

  Future<void> _addSampleData() async {
    // Add sample friends
    await _friendRepository.addFriend(Friend(
      userId: _currentUserId,
      friendId: 2,
      friendName: 'Alice',
      friendProfilePicture: '',
      hasUpcomingEvents: true,
    ));

    await _friendRepository.addFriend(Friend(
      userId: _currentUserId,
      friendId: 3,
      friendName: 'Bob',
      friendProfilePicture: '',
      hasUpcomingEvents: false,
    ));

    // Add sample events
    await _eventRepository.addEvent(Event(
      name: 'Birthday Party',
      date: '2024-12-25',
      location: 'Alice\'s House',
      description: 'Celebrating Alice\'s Birthday',
      userId: 2, // Event for Alice
    ));
  }

  Future<void> _fetchFriendsWithEvents() async {
    print("Fetching friends with events...");
    final friends = await _friendRepository.fetchFriends(_currentUserId);

    final List<Map<String, dynamic>> friendsWithEvents = [];
    for (final friend in friends) {
      print("Fetching events for friend: ${friend.friendName}");
      final events = await _eventRepository.fetchEventsForUser(friend.friendId);
      friendsWithEvents.add({
        'friend': friend,
        'events': events.map((e) => e.name).toList(),
      });
    }

    setState(() {
      print("Setting state with friends and events...");
      _friendsWithEvents = friendsWithEvents;
    });
  }

  final List<Widget> _pages = [
    const Center(child: Text('Friends List')),
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
                                : 'assets/default_profile.png',
                          ),
                        ),
                        title: Text(friend.friendName),
                        subtitle: Text(
                          events.isEmpty
                              ? 'No Upcoming Events'
                              : events.join('\n'), // Display event names
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
