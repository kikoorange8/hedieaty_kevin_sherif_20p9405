import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class GiftImageCacheService {
  // Pick and resize an image, then convert it to Base64
  Future<String?> pickAndResizeImage() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final imageBytes = await pickedFile.readAsBytes();
        final decodedImage = img.decodeImage(imageBytes);
        final resizedImage = img.copyResize(decodedImage!, width: 64, height: 64);
        return base64Encode(img.encodeJpg(resizedImage)); // Return Base64 string
      }
    } catch (e) {
      print("Error picking or resizing image: $e");
    }
    return null;
  }

  // Decode a Base64 string to Uint8List for displaying
  Uint8List? decodeBase64Image(String? base64Image) {
    try {
      if (base64Image == null || base64Image.isEmpty) return null;
      return base64Decode(base64Image);
    } catch (e) {
      print("Error decoding Base64 image: $e");
      return null;
    }
  }

  // Handle adding or editing an image
  Future<String?> handleImage(String? currentImage) async {
    try {
      final newImage = await pickAndResizeImage();
      return newImage ?? currentImage; // Keep the current image if no new image is selected
    } catch (e) {
      print("Error handling image: $e");
      return currentImage;
    }
  }

  // Remove an image by returning an empty string
  String removeImage() {
    return ""; // Return empty string when removing the image
  }
}
