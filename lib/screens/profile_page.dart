import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../repositories/user_repository.dart';
import '../models/user_model.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserRepository _userRepository = UserRepository();
  late Future<UserModel?> _userFuture;
  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser();
  }

  Future<UserModel?> _fetchUser() async {
    return await _userRepository.fetchUserById(widget.userId);
  }

  Future<void> _updateField(String field, String newValue) async {
    final user = await _userRepository.fetchUserById(widget.userId);
    if (user != null) {
      final updatedUser = user.copyWith(
        name: field == "Name" ? newValue : null,
        email: field == "Email" ? newValue : null,
        phoneNumber: field == "Phone" ? newValue : null,
      );
      await _userRepository.updateUser(updatedUser);
      setState(() {
        _userFuture = Future.value(updatedUser);
      });
    }
  }

  void _showEditDialog(String title, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $title"),
          content: TextField(controller: controller),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                _updateField(title, controller.text);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: FutureBuilder<UserModel?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) return const Center(child: Text("User not found"));

          final user = snapshot.data!;
          return Column(
            children: [
              ListTile(
                title: Text("Name: ${user.name}"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog("Name", user.name),
                ),
              ),
              ListTile(
                title: Text("Email: ${user.email}"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog("Email", user.email),
                ),
              ),
              ListTile(
                title: Text("Phone: ${user.phoneNumber}"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog("Phone", user.phoneNumber),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signup');
                },
                child: const Text("Logout"),
              ),
            ],
          );
        },
      ),
    );
  }
}
