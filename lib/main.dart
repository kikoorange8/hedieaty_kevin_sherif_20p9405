import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/user_model.dart';
import 'repositories/user_repository.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final UserRepository userRepository = UserRepository();

  // Check if a default user exists
  final List<User> users = await userRepository.fetchUsers();
  int? currentUserId;

  if (users.isEmpty) {
    // If no user exists, create a default user
    final newUser = User(name: 'Default User', email: 'default@example.com');
    currentUserId = await userRepository.addUser(newUser);
    print("Default user created with ID: $currentUserId");
  } else {
    // Use the first user's ID as the default (for now)
    currentUserId = users.first.id;
    print("Default user loaded with ID: $currentUserId");
  }

  runApp(MyApp(currentUserId: currentUserId!));
}

class MyApp extends StatelessWidget {
  final int currentUserId;

  const MyApp({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(currentUserId: currentUserId),
    );
  }
}
