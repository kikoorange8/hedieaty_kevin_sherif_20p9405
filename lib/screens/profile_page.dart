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

    if (currentUser != null) {
      _userId = currentUser.uid;
      print("User ID: $_userId");
      _loadProfileImage();
      _fetchUserDetails();
    } else {
      // Handle the case where the user is not authenticated
      print("Error: No authenticated user found.");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login'); // Redirect to login page
      });
    }
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

  // Logout user
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to LoginPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Profile Image
            CircleAvatar(
              radius: 70,
              backgroundColor: Colors.indigo.shade100,
              backgroundImage: _profileImagePath != null && _profileImagePath!.startsWith('lib')
                  ? AssetImage(_profileImagePath!) as ImageProvider
                  : FileImage(File(_profileImagePath!)),
              child: _profileImagePath == null
                  ? const Icon(Icons.person, size: 50, color: Colors.indigo)
                  : null,
            ),
            const SizedBox(height: 15),

            // Change Profile Image Button
            ElevatedButton(
              onPressed: _updateProfileImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Change Profile Image",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),

            // Static and Editable Fields
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildStaticField("Email", _userDetails["email"] ?? "Unknown"),
                  _buildEditableField("Name", _userDetails["name"] ?? "Unknown", "name"),
                  _buildEditableField(
                    "Phone Number",
                    _userDetails["phoneNumber"] ?? "Unknown",
                    "phoneNumber",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Logout Button
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticField(String label, String value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  Widget _buildEditableField(String label, String value, String fieldKey) {
    final TextEditingController controller = TextEditingController(text: value);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: Colors.indigo),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Edit $label"),
                content: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "Enter new $label",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                  ),
                  TextButton(
                    onPressed: () async {
                      await _updateField(fieldKey, controller.text.trim());
                      Navigator.pop(context);
                    },
                    child: const Text("Save", style: TextStyle(color: Colors.indigo)),
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