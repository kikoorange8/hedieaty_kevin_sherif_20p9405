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
  testDatabase();

  // Comment out the app launch for now
  // runApp(const MyApp());
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
  // Delete the existing database for testing
  await DatabaseHelper.instance.deleteDatabaseFile();

  final userRepository = UserRepository();
  final friendRepository = FriendRepository();
  final eventRepository = EventRepository();

  print("Starting Database Tests...");

  // Insert sample data
  await userRepository.addUser(User(name: "John Doe", email: "john@example.com"));
  await friendRepository.addFriend(Friend(
    userId: 1,
    friendId: 2,
    friendName: "Alice",
    friendProfilePicture: "",
    hasUpcomingEvents: true,
  ));
  await eventRepository.addEvent(Event(
    name: "Birthday Party",
    date: "2024-12-25",
    userId: 2,
  ));

  // Fetch and print data
  final users = await userRepository.fetchUsers();
  print("Users: $users");

  final friends = await friendRepository.fetchFriends(1);
  print("Friends: $friends");

  final events = await eventRepository.fetchEventsForUser(2);
  print("Events: $events");

  print("Database Tests Completed.");
}
