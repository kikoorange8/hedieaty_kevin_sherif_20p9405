import 'package:flutter/material.dart';
import 'package:hedieaty_kevin_sherif_20p9405/models/event_model.dart';
import 'package:hedieaty_kevin_sherif_20p9405/models/friend_model.dart';
import 'package:hedieaty_kevin_sherif_20p9405/models/user_model.dart';
import 'screens/home_screen.dart';
import 'database/database_helper.dart';

// Database Testing
import 'repositories/event_repository.dart';
import 'repositories/friend_repositroy.dart';
import 'repositories/gift_repository.dart';
import 'repositories/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Initialize Flutter bindings

  // Call the database testing function
  //testDatabase();


   runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// Database Testing Function
void testDatabase() async {
  // Delete existing database for testing purposes
  await DatabaseHelper.instance.deleteDatabaseFile();

  final userRepository = UserRepository();
  final friendRepository = FriendRepository();
  final eventRepository = EventRepository();

  print("Starting Database Tests...");

  // Insert sample user
  await userRepository.addUser(User(name: "John Doe", email: "john@example.com"));

  // Insert multiple friends
  print("Inserting Friends...");
  await friendRepository.addFriend(Friend(
    userId: 1,
    friendId: 2,
    friendName: "Alice",
    friendProfilePicture: "",
    hasUpcomingEvents: true,
  ));
  await friendRepository.addFriend(Friend(
    userId: 1,
    friendId: 3,
    friendName: "Bob",
    friendProfilePicture: "",
    hasUpcomingEvents: true,
  ));
  await friendRepository.addFriend(Friend(
    userId: 1,
    friendId: 4,
    friendName: "Charlie",
    friendProfilePicture: "",
    hasUpcomingEvents: false,
  ));

  // Insert multiple events
  print("Inserting Events...");
  await eventRepository.addEvent(Event(
    name: "Alice's Birthday Party",
    date: "2024-12-25",
    userId: 2,
  ));
  await eventRepository.addEvent(Event(
    name: "Alice's Wedding",
    date: "2025-06-10",
    userId: 2,
  ));
  await eventRepository.addEvent(Event(
    name: "Bob's Graduation",
    date: "2024-05-15",
    userId: 3,
  ));

  // Fetch and print data
  print("Fetching Users...");
  final users = await userRepository.fetchUsers();
  print("Users: $users");

  print("Fetching Friends...");
  final friends = await friendRepository.fetchFriends(1);
  print("Friends: $friends");

  print("Fetching Events...");
  for (var friend in friends) {
    final events = await eventRepository.fetchEventsForUser(friend.friendId);
    print("${friend.friendName}'s Events: $events");
  }

  print("Database Tests Completed.");
}

