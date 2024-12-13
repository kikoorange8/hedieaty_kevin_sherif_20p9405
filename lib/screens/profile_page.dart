import 'package:flutter/material.dart';
import '../repositories/user_repository.dart';
import '../models/user_model.dart';

class ProfilePage extends StatelessWidget {
  final UserRepository _userRepository = UserRepository();

  ProfilePage({super.key});

  Future<User?> _fetchUser() async {
    final users = await _userRepository.fetchUsers();
    return users.isNotEmpty ? users.first : null; // Assuming the first user
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<User?>(
        future: _fetchUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No user found.'));
          }
          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
                const SizedBox(height: 16),
                Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Email: ${user.email}'),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: () {}, child: const Text('Edit Profile')),
              ],
            ),
          );
        },
      ),
    );
  }
}
