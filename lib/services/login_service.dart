import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty_kevin_sherif_20p9405/repositories/user_repository.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginService {
  //final FirebaseAuth _auth = FirebaseAuth.instance;

  // testing
  final FirebaseAuth _auth;
  // Allow injecting a custom FirebaseAuth instance for testing
  LoginService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  // Login with email and password
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
        print("Wrong Email or Password: $e");
      return null;
    }
  }

  Future<void> handleLogin(String userId) async {
    final UserRepository userRepository = UserRepository();

    // Check if the user exists locally
    final userExists = await userRepository.isUserInLocalDatabase(userId);

    if (!userExists) {
      // Fetch user details from Firebase
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
      final userSnapshot = await dbRef.child("users/$userId").get();

      if (userSnapshot.exists) {
        // Fetch user data and filter out unsupported fields
        final userData = Map<String, dynamic>.from(userSnapshot.value as Map);

        // Add 'id' explicitly
        userData['id'] = userId;

        // Remove unsupported fields
        userData.remove('friends');
        userData.remove('incomingRequests');

        // Add user to local database
        await userRepository.addUserIfNotExists(userData);
        print("User synced to local database: ${userData['name']}");
      } else {
        print("User not found in Firebase.");
        throw Exception("User data missing in Firebase.");
      }
    }
  }

}
