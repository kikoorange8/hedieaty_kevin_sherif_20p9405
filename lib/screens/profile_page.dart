import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/fetch_user_service.dart';
import '../services/edit_user_service.dart';
import '../services/image_cache_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String _userId;
  Map<String, String?> _userDetails = {"name": "", "phoneNumber": "", "email": ""};
  String? _profileImagePath;

  final FetchUserService _fetchUserService = FetchUserService();
  final EditUserService _editUserService = EditUserService();
  final ImageCacheService _imageCacheService = ImageCacheService();

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    _userId = currentUser?.uid ?? '';
    _loadProfileImage();
    _fetchUserDetails();
  }

  // Load image from SharedPreferences
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath =
          prefs.getString('profile_image_$_userId') ?? 'lib/assets/default_profile.png';
    });
  }

  // Fetch user details
  Future<void> _fetchUserDetails() async {
    final details = await _fetchUserService.fetchUserDetails(_userId);
    setState(() {
      _userDetails = details;
    });
  }

  // Update user field
  Future<void> _updateField(String field, String newValue) async {
    await _editUserService.updateField(_userId, field, newValue);
    _fetchUserDetails(); // Refresh details
  }

  // Update profile image
  Future<void> _updateProfileImage() async {
    final pickedImage = await _imageCacheService.pickImage();
    if (pickedImage != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_$_userId', pickedImage.path);

      setState(() {
        _profileImagePath = pickedImage.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundImage: _profileImagePath != null && _profileImagePath!.startsWith('lib')
                  ? AssetImage(_profileImagePath!) as ImageProvider
                  : FileImage(File(_profileImagePath!)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _updateProfileImage,
              child: const Text("Change Profile Image"),
            ),
            const SizedBox(height: 20),
            _buildStaticField("Email", _userDetails["email"] ?? "Unknown"),
            _buildEditableField("Name", _userDetails["name"] ?? "Unknown", "name"),
            _buildEditableField(
                "Phone Number", _userDetails["phoneNumber"] ?? "Unknown", "phoneNumber"),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticField(String label, String value) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
    );
  }

  Widget _buildEditableField(String label, String value, String fieldKey) {
    final TextEditingController controller = TextEditingController(text: value);

    return ListTile(
      title: Text(label),
      subtitle: Text(value),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Edit $label"),
                content: TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: "Enter new $label"),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () async {
                      await _updateField(fieldKey, controller.text.trim());
                      Navigator.pop(context);
                    },
                    child: const Text("Save"),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
