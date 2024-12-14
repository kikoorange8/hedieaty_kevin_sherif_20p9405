import 'package:flutter/material.dart';
import '../repositories/user_repository.dart';
import '../models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserRepository _userRepository = UserRepository();
  int? _userId;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    // Simulate fetching user ID from local storage (use SharedPreferences or Firebase in real apps)
    _userId = 1; // Replace with dynamic user ID fetching logic
    await _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    if (_userId != null) {
      final users = await _userRepository.fetchUsers();
      setState(() {
        _user = users.firstWhere((user) => user.id == _userId, orElse: () => User(name: 'Guest', email: 'guest@example.com'));
      });
    }
  }

  Future<void> _editUserProfile() async {
    final nameController = TextEditingController(text: _user?.name);
    final emailController = TextEditingController(text: _user?.email);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedUser = User(
                  id: _userId,
                  name: nameController.text,
                  email: emailController.text,
                );
                await _userRepository.updateUser(updatedUser);
                Navigator.pop(context);
                await _fetchUserProfile();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Text(
              _user!.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Email: ${_user!.email}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _editUserProfile,
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
