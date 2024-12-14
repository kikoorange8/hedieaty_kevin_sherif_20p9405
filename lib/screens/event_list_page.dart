import 'package:flutter/material.dart';
import '../repositories/event_repository.dart';
import '../models/event_model.dart';

class EventListPage extends StatefulWidget {
  final int currentUserId;
  final bool isFriendEvents;

  const EventListPage({
    super.key,
    required this.currentUserId,
    this.isFriendEvents = false,
  });

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final EventRepository _eventRepository = EventRepository();
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
    });

    // Fetch events based on the passed userId
    final events = await _eventRepository.fetchEventsForUser(widget.currentUserId);

    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isFriendEvents
            ? const Text('Friend\'s Events')
            : const Text('My Events'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
          ? const Center(
        child: Text(
          'No events available.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return Card(
            margin: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 16,
            ),
            child: ListTile(
              title: Text(event.name),
              subtitle: Text(
                'Date: ${event.date}\nLocation: ${event.location}',
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                // Optionally, navigate to a detailed event page
              },
            ),
          );
        },
      ),
    );
  }
}
