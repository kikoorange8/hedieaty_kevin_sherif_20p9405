import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class NotificationListener {
  late DatabaseReference _notificationsRef;
  final List<Map<String, dynamic>> _notificationQueue = []; // Queue to store notifications
  bool _isDisplayingNotification = false; // Flag to indicate if a notification is being displayed

  void startListening(String userId, BuildContext context) {
    _notificationsRef = FirebaseDatabase.instance.ref().child('notifications/$userId');

    _notificationsRef.onChildAdded.listen((event) {
      // Handle the notification when a new notification is added
      final notificationData = event.snapshot.value as Map?;
      final notificationKey = event.snapshot.key; // Get the key of the notification

      if (notificationData != null) {
        _notificationQueue.add({
          'key': notificationKey,
          'message': notificationData['message'],
        }); // Add the notification to the queue

        // If no notification is currently being displayed, start displaying notifications
        if (!_isDisplayingNotification) {
          _processNotificationQueue(context, userId);
        }
      }
    });
  }

  void stopListening() {
    _notificationsRef.onChildAdded.listen((_) {}).cancel(); // Stop listening
  }

  void _processNotificationQueue(BuildContext context, String userId) async {
    // Check if there are notifications in the queue
    while (_notificationQueue.isNotEmpty) {
      _isDisplayingNotification = true;

      // Get the next notification from the queue
      final notification = _notificationQueue.removeAt(0);

      // Show the notification
      await _showNotification(context, notification['message']);

      // Delete the notification from Firebase
      await _deleteNotification(userId, notification['key']);
    }

    // When the queue is empty, reset the flag
    _isDisplayingNotification = false;
  }

  Future<void> _deleteNotification(String userId, String? notificationKey) async {
    if (notificationKey != null) {
      await _notificationsRef.child(notificationKey).remove();
    }
  }

  Future<void> _showNotification(BuildContext context, String message) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );

    // Wait for the SnackBar to finish displaying
    await Future.delayed(const Duration(seconds: 2));
  }
}
