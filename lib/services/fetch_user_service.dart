import 'package:firebase_database/firebase_database.dart';

class FetchUserService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<Map<String, String?>> fetchUserDetails(String userId) async {
    try {
      final snapshot = await _dbRef.child("users").child(userId).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return {
          "name": data["name"] as String?,
          "phoneNumber": data["phoneNumber"] as String?,
          "email": data["email"] as String?,
        };
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
    return {"name": "Unknown", "phoneNumber": "Unknown", "email": "Unknown"};
  }
}
