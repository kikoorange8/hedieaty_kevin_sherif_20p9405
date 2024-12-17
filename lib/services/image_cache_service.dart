import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageCacheService {
  // Cache the image locally using SharedPreferences (for user profile)
  Future<void> cacheLocally(String userId, String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_$userId', imagePath);
      print('Profile image cached locally for user $userId');
    } catch (e) {
      print("Error caching image locally: $e");
    }
  }

  // Placeholder function to cache image in Firebase
  Future<void> cacheToFirebase(String userId, String imagePath) async {
    // This function will be implemented later to upload to Firebase
    print('Caching image to Firebase is not yet implemented for user $userId');
  }

  // Pick an image using ImagePicker
  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Load the cached image from SharedPreferences
  Future<String?> loadCachedImage(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('profile_image_$userId');
      if (imagePath != null) {
        return imagePath;
      } else {
        return 'assets/default_profile.png';  // Return default image if not cached
      }
    } catch (e) {
      print("Error loading cached image: $e");
      return 'assets/default_profile.png'; // Default image on error
    }
  }
}
