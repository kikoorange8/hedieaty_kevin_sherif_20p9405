import 'package:flutter/material.dart';
// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:hedieaty_kevin_sherif_20p9405/screens/home_screen.dart';
import 'package:hedieaty_kevin_sherif_20p9405/screens/login.dart';
import 'firebase_options.dart';
// sql database
import 'database/database_helper.dart';
// Screens
import 'screens/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Delete the database
  await DatabaseHelper.instance.deleteDatabaseFile();

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      // Define routes
      routes: {
        '/': (context) => const SignupPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomeScreen(currentUserId: ''),
      },
      initialRoute: '/', // Starting page
    );
  }
}
