import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import '../database/database_helper.dart';
import '../repositories/gift_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/event_repository.dart';
import '../models/gift_model.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../services/gift_image_cache_service.dart';
import 'gift_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PledgedGiftsPage extends StatefulWidget {
  @override
  _PledgedGiftsPageState createState() => _PledgedGiftsPageState();
}

class _PledgedGiftsPageState extends State<PledgedGiftsPage> {
  List<Map<String, dynamic>> _detailedPledgedGifts = [];
  final GiftRepository _giftRepository = GiftRepository();
  final UserRepository _userRepository = UserRepository();
  final EventRepository _eventRepository = EventRepository();
  final GiftImageCacheService _imageService = GiftImageCacheService();

  @override
  void initState() {
    super.initState();
    _fetchPledgedGiftsDetails();
  }


  Future<void> _toggleGiftStatus(String friendId, String eventId, String giftId,
      String currentStatus) async {
    String newStatus = currentStatus == "Purchased" ? "Pledged" : "Purchased";
    try {
      // Update the status in Firebase and SQLite
      await _updateGiftStatus(friendId, eventId, giftId, newStatus);

      // Fetch the gift name from SQLite
      final giftDetails = await _giftRepository.getGiftById(giftId);
      final giftName = giftDetails?.name ?? "Unnamed Gift";

      // Send a notification based on the new status
      String notificationMessage = newStatus == "Purchased"
          ? "Gift $giftName has been purchased!"
          : "Gift $giftName has been returned to pledged status!";
      await _sendNotificationToFriend(
          giftName, friendId, message: notificationMessage);

      // Refresh the pledged gifts list
      await _fetchPledgedGiftsDetails();
    } catch (e) {
      print("Error toggling gift status: $e");
    }
  }

  Future<void> _sendNotificationToFriend(String giftName, String friendId,
      {required String message}) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Send the notification to Firebase for the friend
      final notificationRef = FirebaseDatabase.instance
          .ref('notifications/$friendId')
          .push(); // Pushes a new notification for the friend

      // Set notification data
      await notificationRef.set({
        'message': message,
        'from': currentUserId,
        'timestamp': DateTime.now().toIso8601String(),
      });

      print("Notification sent to $friendId for gift $giftName: $message");
    } catch (e) {
      print("Error sending notification to $friendId: $e");
    }
  }


  Future<void> _fetchPledgedGiftsDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    List<Map<String, dynamic>> detailedPledgedGifts = [];

    for (String key in allKeys) {
      if (key.startsWith('pledgedGifts_')) {
        List<String>? giftIds = prefs.getStringList(key);
        if (giftIds != null && giftIds.isNotEmpty) {
          for (String gift in giftIds) {
            final parts = gift.split('|');
            if (parts.length == 3) {
              final friendId = parts[0];
              final eventId = parts[1];
              final giftId = parts[2];

              // Fetch details from the database
              Gift? giftDetails = await _giftRepository.getGiftById(giftId);
              UserModel? userDetails = await _userRepository.fetchUserById(
                  friendId);
              Event? eventDetails = await _eventRepository.getEventById(
                  eventId);

              if (giftDetails != null && userDetails != null &&
                  eventDetails != null) {
                detailedPledgedGifts.add({
                  'giftId': giftId,
                  'friendId': friendId,
                  'eventId': eventId,
                  'giftName': giftDetails.name,
                  'giftPrice': giftDetails.price,
                  'friendName': userDetails.name,
                  'eventName': eventDetails.name,
                  'eventDate': _formatDate(eventDetails.date),
                  'status': giftDetails.status, // Track current status
                  'giftImage': giftDetails.image, // Add image field
                });
              }
            }
          }
        }
      }
    }

    setState(() {
      _detailedPledgedGifts = detailedPledgedGifts;
    });
  }

  String _formatDate(String date) {
    final eventDate = DateTime.parse(date);
    return "${eventDate.day}/${eventDate.month}/${eventDate.year}";
  }

  Future<void> _updateGiftStatus(String friendId, String eventId, String giftId,
      String newStatus) async {
    final dbRef = FirebaseDatabase.instance.ref();
    final db = await DatabaseHelper.instance.database;

    try {
      // Update the status in Firebase
      await dbRef.child('events/$friendId/$eventId/gifts/$giftId').update(
          {'status': newStatus});

      // Update the status in SQLite
      await db.update(
        'gifts',
        {'status': newStatus},
        where: 'id = ?',
        whereArgs: [giftId],
      );

      print("Gift $giftId updated to $newStatus successfully.");
    } catch (e) {
      print("Error updating gift: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pledged Gifts'),
        backgroundColor: Colors.teal,
      ),
      body: _detailedPledgedGifts.isEmpty
          ? Center(
        child: const Text(
          'No pledged gifts found.',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
        ),
      )
          : ListView.builder(
        itemCount: _detailedPledgedGifts.length,
        itemBuilder: (context, index) {
          final giftDetails = _detailedPledgedGifts[index];
          final giftImage = _imageService.decodeBase64Image(
              giftDetails['giftImage']);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GiftDetailsPage(
                        giftId: giftDetails['giftId'],
                      ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 6,
              shadowColor: Colors.teal.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: giftImage != null ? MemoryImage(
                          giftImage) : null,
                      radius: 32,
                      backgroundColor: Colors.teal.shade100,
                      child: giftImage == null
                          ? const Icon(
                          Icons.card_giftcard, size: 32, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gift Name: ${giftDetails['giftName']}',
                            style: TextStyle(fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal),
                          ),
                          Text(
                            'Gift Price: \$${giftDetails['giftPrice']}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.teal.shade800),
                          ),
                          Text(
                            'Friend Name: ${giftDetails['friendName']}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.teal.shade800),
                          ),
                          Text(
                            'Event Name: ${giftDetails['eventName']}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.teal.shade800),
                          ),
                          Text(
                            'Event Date: ${giftDetails['eventDate']}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.teal.shade800),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Icon(
                          Icons.handshake,
                          color: giftDetails['status'] == "Purchased"
                              ? Colors.grey
                              : Colors.teal.shade700,
                          size: 30,
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          icon: Icon(
                            Icons.shopping_cart,
                            color: giftDetails['status'] == "Purchased"
                                ? Colors.amber
                                : Colors.teal.shade400,
                          ),
                          onPressed: () async {
                            await _toggleGiftStatus(
                              giftDetails['friendId'],
                              giftDetails['eventId'],
                              giftDetails['giftId'],
                              giftDetails['status'],
                            );

                            String statusMessage =
                            giftDetails['status'] == "Pledged"
                                ? "Gift purchased"
                                : "Gift returned to pledged status";

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(statusMessage),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}