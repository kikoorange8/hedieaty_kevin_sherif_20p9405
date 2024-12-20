import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../services/gift_image_cache_service.dart';
import '../database/database_helper.dart';
import 'package:firebase_database/firebase_database.dart';
import 'gift_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FriendEventGiftList extends StatefulWidget  {

  final String currentUserId;
  final String friendId;
  final Map<String, dynamic> event;

  const FriendEventGiftList({
    super.key,
    required this.currentUserId,
    required this.friendId,
    required this.event,
  });


  @override
  State<FriendEventGiftList> createState() => _FriendEventGiftListState();
}
class _FriendEventGiftListState extends State<FriendEventGiftList> {
  late Future<List<Map<String, dynamic>>> _giftsFuture;

  @override
  void initState() {
    super.initState();
    _initializeGiftsFuture();
  }

  Color _getIconColor(String status, bool isPledgedByUser) {
    if (status == "Purchased") {
      return Colors.amber; // Gold for purchased
    } else if (status == "Pledged") {
      return isPledgedByUser ? Colors.blue : Colors
          .red; // Blue for user's pledge, red for others
    } else if (status == "Available") {
      return Colors.green; // Green for available
    }
    return Colors.grey; // Default color
  }

  Future<bool> _isPledgedByUser(String friendId, String eventId,
      String giftId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'pledgedGifts_${FirebaseAuth.instance.currentUser!.uid}';
    List<String> pledgedGifts = prefs.getStringList(key) ?? [];
    return pledgedGifts.contains('$friendId|$eventId|$giftId');
  }

  Future<void> _updateGiftStatusAndRefresh(String friendId, String eventId,
      String giftId, String newStatus) async {
    try {
      await _updateGiftStatus(friendId, eventId, giftId, newStatus);
      await _refreshGifts(); // Refresh the gifts list
    } catch (e) {
      print("Error updating gift: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<void> _refreshGifts() async {
    setState(() {
      _giftsFuture = _fetchGifts(widget.event['id']);
    });
  }

  Future<List<Map<String, dynamic>>> _fetchGifts(String eventId) async {
    final db = await DatabaseHelper.instance.database;
    return await db.query(
      'gifts',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
  }

  Future<void> _updateGiftStatus(String friendId, String eventId, String giftId,
      String newStatus) async {
    final dbRef = FirebaseDatabase.instance.ref();
    final db = await DatabaseHelper.instance.database;

    try {
      // Fetch latest gift details from Firebase
      final giftSnapshot = await dbRef.child(
          'events/$friendId/$eventId/gifts/$giftId').get();
      if (!giftSnapshot.exists) {
        throw Exception("Gift $giftId not found in Firebase.");
      }

      final giftData = Map<String, dynamic>.from(giftSnapshot.value as Map);

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

      // Update the status in SharedPreferences if needed
      final prefs = await SharedPreferences.getInstance();
      final key = 'pledgedGifts_${FirebaseAuth.instance.currentUser!.uid}';
      List<String> pledgedGifts = prefs.getStringList(key) ?? [];
      final giftKey = '$friendId|$eventId|$giftId';

      if (newStatus == 'Pledged' && !pledgedGifts.contains(giftKey)) {
        pledgedGifts.add(giftKey);
      } else if (newStatus == 'Available' && pledgedGifts.contains(giftKey)) {
        pledgedGifts.remove(giftKey);
      }
      await prefs.setStringList(key, pledgedGifts);

      print("Gift $giftId updated to $newStatus successfully.");
    } catch (e) {
      print("Error updating gift $giftId: $e");
    }
  }

  Future<List<String>> _getPledgedGiftsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'pledgedGifts_${FirebaseAuth.instance.currentUser!.uid}';
    return prefs.getStringList(key) ?? [];
  }

  Future<void> pledgeGiftLocally(String friendId, String eventId,
      String giftId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'pledgedGifts_${FirebaseAuth.instance.currentUser!.uid}';

    // Fetch existing pledged gifts
    List<String> pledgedGifts = prefs.getStringList(key) ?? [];
    final giftKey = '$friendId|$eventId|$giftId';

    if (!pledgedGifts.contains(giftKey)) {
      pledgedGifts.add(giftKey);
      await prefs.setStringList(key, pledgedGifts);
      print("Gift $giftId pledged locally.");
    }
  }

  Future<void> unpledgeGiftLocally(String friendId, String eventId,
      String giftId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'pledgedGifts_${FirebaseAuth.instance.currentUser!.uid}';

    // Fetch existing pledged gifts
    List<String> pledgedGifts = prefs.getStringList(key) ?? [];
    final giftKey = '$friendId|$eventId|$giftId';

    if (pledgedGifts.contains(giftKey)) {
      pledgedGifts.remove(giftKey);
      await prefs.setStringList(key, pledgedGifts);
      print("Gift $giftId unpledged locally.");
    }
  }

  Future<void> pledgeGift(String friendId, String eventId,
      String giftId) async {
    final dbRef = FirebaseDatabase.instance.ref();

    await dbRef
        .child('events/$friendId/$eventId/gifts/$giftId')
        .update({'status': 'Pledged'});
  }

  Future<void> unpledgeGift(String friendId, String eventId,
      String giftId) async {
    final dbRef = FirebaseDatabase.instance.ref();

    await dbRef
        .child('events/$friendId/$eventId/gifts/$giftId')
        .update({'status': 'Available'});
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

  void _initializeGiftsFuture() {
    _giftsFuture = _fetchGifts(widget.event['id']);
  }

  @override
  Widget build(BuildContext context) {
    final imageService = GiftImageCacheService();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible AppBar with event details
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            backgroundColor: Colors.indigo,
            flexibleSpace: FlexibleSpaceBar(
              title: null,
              background: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      widget.event['name'] ?? 'Unnamed Event',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Date: ${_formatDate(widget.event['date'] ?? '')}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Description: ${widget.event['description'] ??
                          'No description'}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Status: ${_getEventStatus(widget.event['date'] ?? '')}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getEventStatusColor(
                          _getEventStatus(widget.event['date'] ?? ''),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Static header for "Gifts" section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                "Gifts",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
          ),

          // List of gifts
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchGifts(widget.event['id']),
            // Fetch gifts for the event
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: const Center(child: Text("Error loading gifts.")),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverFillRemaining(
                  child: const Center(child: Text("No gifts found.")),
                );
              }

              final gifts = snapshot.data!;
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final gift = gifts[index];
                    final giftImage = imageService.decodeBase64Image(
                        gift['image']);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                        title: Text(gift['name']?.toString() ?? "Unnamed Gift"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(gift['description']?.toString() ??
                                "No description"),
                            Text("Price: \$${int.tryParse(
                                gift['price']?.toString() ?? '0') ?? 0}"),
                          ],
                        ),
                        trailing: IconButton(
                          icon: FutureBuilder<bool>(
                            future: _isPledgedByUser(widget.friendId, widget.event['id']?.toString() ?? '', gift['id']?.toString() ?? ''),
                            builder: (context, snapshot) {
                              final isPledgedByUser = snapshot.data ?? false;
                              return Icon(
                                Icons.handshake,
                                color: _getIconColor(gift['status']?.toString() ?? '', isPledgedByUser),
                              );
                            },
                          ),
                          onPressed: () async {
                            final giftId = gift['id']?.toString() ?? '';
                            final eventId = widget.event['id']?.toString() ?? '';
                            final currentStatus = gift['status']?.toString() ?? '';

                            try {
                              if (currentStatus == "Available") {
                                await _updateGiftStatusAndRefresh(widget.friendId, eventId, giftId, "Pledged");
                              } else if (currentStatus == "Pledged") {
                                final isPledgedByUser = await _isPledgedByUser(widget.friendId, eventId, giftId);
                                if (isPledgedByUser) {
                                  await _updateGiftStatusAndRefresh(widget.friendId, eventId, giftId, "Available");
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Cannot unpledge a gift pledged by someone else.")),
                                  );
                                }
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: ${e.toString()}")),
                              );
                            }
                          },
                        ),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GiftDetailsPage(
                                    giftId: gift['id']?.toString() ?? '',
                                  ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  childCount: gifts.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}