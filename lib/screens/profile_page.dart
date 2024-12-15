import 'package:flutter/material.dart';
import '../repositories/user_repository.dart';
import '../models/user_model.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserRepository _userRepository = UserRepository();
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser();
  }

  Future<User> _fetchUser() async {
    final user = await _userRepository.fetchUserById(widget.userId);
    if (user == null) {
      throw Exception("User not found");
    }
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name: ${user.name}"),
                  Text("Email: ${user.email}"),
                ],
              ),
            );
          } else {
            return const Center(child: Text("User not found."));
          }
        },
      ),
    );
  }
}
