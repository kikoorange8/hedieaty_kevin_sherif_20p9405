import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend's Gift List"),
      ),
      body: const Center(
        child: Text("Friend's Gift List Page"),
      ),
    );
  }
}
