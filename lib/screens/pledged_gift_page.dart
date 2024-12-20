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
              UserModel? userDetails = await _userRepository.fetchUserById(friendId);
              Event? eventDetails = await _eventRepository.getEventById(eventId);

              if (giftDetails != null && userDetails != null && eventDetails != null) {
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

  Future<void> _updateGiftStatus(String friendId, String eventId, String giftId, String newStatus) async {
    final dbRef = FirebaseDatabase.instance.ref();
    final db = await DatabaseHelper.instance.database;

    try {
      // Update the status in Firebase
      await dbRef.child('events/$friendId/$eventId/gifts/$giftId').update({'status': newStatus});

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

  Future<void> _toggleGiftStatus(String friendId, String eventId, String giftId, String currentStatus) async {
    String newStatus = currentStatus == "Purchased" ? "Pledged" : "Purchased";
    try {
      await _updateGiftStatus(friendId, eventId, giftId, newStatus);
      await _fetchPledgedGiftsDetails();
    } catch (e) {
      print("Error toggling gift status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pledged Gifts'),
      ),
      body: _detailedPledgedGifts.isEmpty
          ? Center(
        child: const Text(
          'No pledged gifts found.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        itemCount: _detailedPledgedGifts.length,
        itemBuilder: (context, index) {
          final giftDetails = _detailedPledgedGifts[index];
          final giftImage = _imageService.decodeBase64Image(giftDetails['giftImage']);
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Display gift image or placeholder
                  CircleAvatar(
                    backgroundImage: giftImage != null ? MemoryImage(giftImage) : null,
                    radius: 32,
                    backgroundColor: Colors.grey[200],
                    child: giftImage == null
                        ? const Icon(Icons.card_giftcard, size: 32, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gift Name: ${giftDetails['giftName']}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Gift Price: \$${giftDetails['giftPrice']}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          'Friend Name: ${giftDetails['friendName']}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          'Event Name: ${giftDetails['eventName']}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          'Event Date: ${giftDetails['eventDate']}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Icon(
                        Icons.handshake,
                        color: giftDetails['status'] == "Purchased" ? Colors.grey : Colors.green,
                        size: 30,
                      ),
                      const SizedBox(height: 8),
                      IconButton(
                        icon: Icon(
                          Icons.shopping_cart,
                          color: giftDetails['status'] == "Purchased" ? Colors.amber : Colors.grey,
                        ),
                        onPressed: () {
                          _toggleGiftStatus(
                            giftDetails['friendId'],
                            giftDetails['eventId'],
                            giftDetails['giftId'],
                            giftDetails['status'],
                          );

                          if (giftDetails['status'] == "Pledged") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Gift purchased"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },

                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
