import 'package:flutter/material.dart';
// Firebase
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty_kevin_sherif_20p9405/screens/home_screen.dart';
import 'package:hedieaty_kevin_sherif_20p9405/screens/login.dart';
import 'package:hedieaty_kevin_sherif_20p9405/screens/signup.dart';
import 'package:sqflite/sqflite.dart';
import 'firebase_options.dart';
// SQL database
import 'database/database_helper.dart';
// Syncing databases
import '../services/sync_event_and_gift_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Uncomment this if you need syncing functionality:
  /*
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    final syncService = SyncEventAndGiftService();
    syncService.sync_event_or_gift_listener();
  }
  */

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
      home: AuthWrapper(), // Wrapper to handle login state
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => HomeScreen(
          currentUserId: FirebaseAuth.instance.currentUser?.uid ?? '',
        ),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // User is signed in, navigate to HomeScreen
      return HomeScreen(currentUserId: currentUser.uid);
    } else {
      // No user is signed in, navigate to SignupPage
      return const SignupPage();
    }
  }
}
