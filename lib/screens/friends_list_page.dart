import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For picking an image
import 'package:shared_preferences/shared_preferences.dart'; // For saving image as preference
import 'package:firebase_auth/firebase_auth.dart';
import '../models/friend_model.dart';
import '../services/friend_request_service.dart';
import '../repositories/friend_repositroy.dart';
import '../services/friends_list_page_service.dart';
import '../services/fetch_friend_event_gift_service.dart';
import 'friends_list_helpers.dart';

class FriendsListPage extends StatefulWidget {
  final String currentUserId;

  const FriendsListPage({super.key, required this.currentUserId});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  final FriendRequestService _friendRequestService = FriendRequestService();
  final FriendRepository _friendRepository = FriendRepository();
  final FriendsListPageService _friendsListPageService = FriendsListPageService();
  final FetchFriendEventsAndGiftsService _fetchFriendEventsAndGiftsService = FetchFriendEventsAndGiftsService();

  late FriendsListHelpers _helpers;

  List<Friend> _friends = [];
  List<Friend> _filteredFriends = [];
  String _searchQuery = "";
  Map<String, String> _friendImages = {}; // Friend ID -> Image path


  @override
  void initState() {
    super.initState();
    _helpers = FriendsListHelpers(
      friendRepository: _friendRepository,
      friendsListPageService: _friendsListPageService,
      fetchFriendEventsAndGiftsService: _fetchFriendEventsAndGiftsService,
    );
    _loadFriends();
    _loadFriendImages();
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

  String _formatDate(String date) {
    final eventDate = DateTime.parse(date);
    return "${eventDate.day}/${eventDate.month}/${eventDate.year}";
  }

  Future<void> _addFriendByPhoneNumber(BuildContext context) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Friend"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter friend's phone number"),
            keyboardType: TextInputType.phone,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final phoneNumber = controller.text.trim();
                Navigator.pop(context);

                try {
                  await _friendRequestService.sendFriendRequest(
                    currentUserId: currentUserId,
                    phoneNumber: phoneNumber,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Friend request sent successfully.")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFriendRequests(BuildContext context) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    try {
      final requests = await _friendRequestService.getIncomingRequests(currentUserId);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Friend Requests"),
            content: requests.isEmpty
                ? const Text("No pending friend requests.")
                : SingleChildScrollView(
              child: Column(
                children: requests.map((request) {
                  return ListTile(
                    title: Text(request["name"] ?? "Unknown"),
                    subtitle: Text("${request["email"]} • ${request["phoneNumber"]}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            await _friendRequestService.acceptFriendRequest(
                              currentUserId,
                              request["uid"]!,
                            );
                            _loadFriends(); // Reload friends list
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            await _friendRequestService.declineFriendRequest(
                              currentUserId,
                              request["uid"]!,
                            );
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // Load friends from SQLite
  Future<void> _loadFriends() async {
    final friendsList = await _helpers.loadFriends(widget.currentUserId);
    setState(() {
      _friends = friendsList;
      _filteredFriends = friendsList;
    });
  }

  // Load saved images from SharedPreferences
  Future<void> _loadFriendImages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _friendImages = prefs.getKeys().fold<Map<String, String>>({}, (map, key) {
        map[key] = prefs.getString(key) ?? "";
        return map;
      });
    });
  }

  // Save a friend's image path to SharedPreferences
  Future<void> _saveFriendImage(String friendId, String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(friendId, imagePath);
    setState(() {
      _friendImages[friendId] = imagePath;
    });
  }

  // Pick an image and save it
  Future<void> _pickImageAndSave(String friendId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await _saveFriendImage(friendId, pickedFile.path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated.")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends List"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search friends by name...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
              onChanged: (query) => _helpers.filterFriends(query, _friends, _friendRepository).then((filteredList) {
                setState(() {
                  _filteredFriends = filteredList;
                });
              }),
            ),
          ),
        ),
      ),


      //ADD AND ACCEPT FRIEND REQUEST BUTOTNS
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () => _addFriendByPhoneNumber(context),
            label: const Text(""),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () => _showFriendRequests(context),
            label: const Text(""),
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),

      body: _filteredFriends.isEmpty
          ? const Center(child: Text("No friends found."))
          : ListView.builder(
        itemCount: _filteredFriends.length,
        itemBuilder: (context, index) {
          final friend = _filteredFriends[index];
          return FutureBuilder<Map<String, dynamic>?>(
            future: _friendRepository.fetchUserDetailsById(friend.friendId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  title: Text("Loading..."),
                  subtitle: Text("Please wait"),
                );
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return ListTile(
                  title: Text("Friend ID: ${friend.friendId}"),
                  subtitle: const Text("User not found"),
                );
              }
              final userData = snapshot.data!;

              return ExpansionTile(
                leading: GestureDetector(
                  onTap: () => _pickImageAndSave(friend.friendId),
                  child: CircleAvatar(
                    backgroundImage: _friendImages[friend.friendId]?.isNotEmpty == true
                        ? FileImage(File(_friendImages[friend.friendId]!))
                        : const AssetImage('lib/assets/default_profile.png') as ImageProvider,
                  ),
                ),
                title: Text(userData['name'] ?? "Unknown Name"),
                subtitle: Text(userData['phoneNumber'] ?? "No Phone Number"),
                children: [
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _helpers.fetchFriendEvents(friend.friendId),
                    builder: (context, eventSnapshot) {
                      if (eventSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (eventSnapshot.hasError) {
                        return const ListTile(
                          title: Text("Error loading events."),
                        );
                      }
                      if (!eventSnapshot.hasData || eventSnapshot.data!.isEmpty) {
                        return const ListTile(
                          title: Text("No events found."),
                        );
                      }

                      final events = List<Map<String, dynamic>>.from(eventSnapshot.data!); // Create a mutable copy

// Sort events by Current, Upcoming, and Passed
                      events.sort((a, b) {
                        final statusA = _getEventStatus(a['date']);
                        final statusB = _getEventStatus(b['date']);

                        final priority = {"Current": 0, "Upcoming": 1, "Passed": 2};
                        return priority[statusA]!.compareTo(priority[statusB]!);
                      });


                      return Column(
                        children: events.map((event) {
                          final status = _getEventStatus(event['date']);
                          return ListTile(
                            title: Text(event['name'] ?? "Unnamed Event"),
                            subtitle: Row(
                              children: [
                                Text(_formatDate(event['date'])),
                                const SizedBox(width: 10),
                                Text(
                                  status,
                                  style: TextStyle(color: _getEventStatusColor(status)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
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
