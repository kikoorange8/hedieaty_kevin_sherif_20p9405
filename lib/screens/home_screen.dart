import 'package:flutter/material.dart';
import 'friends_list_page.dart';
import 'event_list_page.dart';
import 'gift_list_page.dart';
import 'pledged_gift_page.dart';
import 'profile_page.dart';
import 'create_event_list_page.dart';

import '../repositories/event_repository.dart';
import '../models/event_model.dart';

Future<void> addEventsForFriend(int friendId) async {
  final EventRepository eventRepository = EventRepository();

  // Check existing events for this friend
  final existingEvents = await eventRepository.fetchEventsForUser(friendId);

  // Define events to add
  final eventsToAdd = [
    Event(name: "Birthday Party", date: "2024-12-25", userId: friendId),
    Event(name: "Graduation Ceremony", date: "2024-06-15", userId: friendId),
  ];

  for (var event in eventsToAdd) {
    // Add event only if it doesn't exist
    if (!existingEvents.any((e) => e.name == event.name && e.date == event.date)) {
      await eventRepository.addEvent(event);
    }
  }

  print("Events added for friend ID: $friendId");
}

class HomeScreen extends StatefulWidget {
  final int currentUserId;

  const HomeScreen({super.key, required this.currentUserId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Pages for each navigation tab
    final List<Widget> _pages = [
      FriendsListPage(currentUserId: widget.currentUserId),
      EventListPage(currentUserId: widget.currentUserId),
      GiftListPage(userId: widget.currentUserId, isCurrentUser: true),
      PledgedGiftPage(currentUserId: widget.currentUserId), // Corrected parameter name
      ProfilePage(userId: widget.currentUserId),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hedieaty'),
        actions: [
          // Add action to trigger event addition for testing purposes
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Testing adding events to a friend's ID
              await addEventsForFriend(2); // Replace with actual friendId for testing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Events added for testing!')),
              );
            },
          ),
        ],
      ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEventListPage(currentUserId: widget.currentUserId),
            ),
          );
        },
        label: const Text("Create Event/List"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
