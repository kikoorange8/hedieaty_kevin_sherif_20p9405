import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../services/gift_image_cache_service.dart'; // Import for image handling
import '../database/database_helper.dart';
import 'package:firebase_database/firebase_database.dart';


class FriendEventGiftList extends StatelessWidget {
  final String currentUserId;
  final String friendId;
  final Map<String, dynamic> event;

  const FriendEventGiftList({
    super.key,
    required this.currentUserId,
    required this.friendId,
    required this.event,
  });

  Future<void> pledgeGift(String friendId, String eventId, String giftId) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

    try {
      await dbRef
          .child('events/$friendId/$eventId/gifts/$giftId')
          .update({'status': 'Pledged'});
      print("Gift $giftId has been pledged.");
    } catch (e) {
      print("Error pledging gift: $e");
    }
  }

  String _formatDate(String date) {
    final eventDate = DateTime.parse(date);
    return "${eventDate.day}/${eventDate.month}/${eventDate.year}";
  }

  Color _getEventStatusColor(String status) {
    switch (status) {
      case "Current":
        return Colors.green;
      case "Upcoming":
        return Colors.blue;
      case "Passed":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getEventStatus(String date) {
    final now = DateTime.now();
    final eventDate = DateTime.parse(date);

    if (eventDate.year == now.year &&
        eventDate.month == now.month &&
        eventDate.day == now.day) {
      return "Current";
    } else if (eventDate.isAfter(now)) {
      return "Upcoming";
    } else {
      return "Passed";
    }
  }

  Future<void> unpledgeGift(String friendId, String eventId, String giftId) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

    try {
      await dbRef
          .child('events/$friendId/$eventId/gifts/$giftId')
          .update({'status': 'Available'});
      print("Gift $giftId has been unpledged.");
    } catch (e) {
      print("Error unpledging gift: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    final imageService = GiftImageCacheService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Gift List"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Details at the Top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Event Name: ${event['name'] ?? 'Unnamed Event'}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Description: ${event['description'] ?? 'No description'}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Location: ${event['location'] ?? 'No location'}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  "Date: ${_formatDate(event['date'])}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(),
          // Gifts Section
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchGifts(event['id']), // Fetch gifts for the event
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading gifts."));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No gifts found."));
                }

                final gifts = snapshot.data!;
                return ListView.builder(
                  itemCount: gifts.length,
                  itemBuilder: (context, index) {
                    final gift = gifts[index];
                    final giftImage = imageService.decodeBase64Image(gift['image']);
                    final isPledged = gift['status'] == 'Pledged';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: giftImage != null
                            ? CircleAvatar(
                          backgroundImage: MemoryImage(giftImage),
                          radius: 24,
                        )
                            : const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.image_not_supported),
                        ),
                        title: Text(gift['name'] ?? "Unnamed Gift"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(gift['description'] ?? "No description"),
                            Text("Price: \$${gift['price'] ?? '0.00'}"),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.handshake,
                            color: gift['status'] == "Pledged" ? Colors.blue : Colors.grey, // Icon color based on pledge status

                          ),
                          onPressed: () async {
                            try {
                              final giftId = gift['id'].toString(); // Ensure gift ID is a String
                              final eventId = event['id'].toString(); // Ensure event ID is a String

                              if (isPledged) {
                                // Unpledge the gift
                                await unpledgeGift(friendId, eventId, giftId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Unpledged: ${gift['name']}")),
                                );
                              } else {
                                // Pledge the gift
                                await pledgeGift(friendId, eventId, giftId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Pledged: ${gift['name']}")),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: ${e.toString()}")),
                              );
                            }
                          },
                        ),



                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchGifts(String eventId) async {
    // Fetch gifts from SQLite for the given eventId
    final db = await DatabaseHelper.instance.database;
    return await db.query(
      'gifts',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
  }
}
