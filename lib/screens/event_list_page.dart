import 'package:flutter/material.dart';
import '../repositories/event_repository.dart';
import '../models/event_model.dart';

class EventListPage extends StatefulWidget {
  final String currentUserId;

  const EventListPage({super.key, required this.currentUserId});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final EventRepository _eventRepository = EventRepository();
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final events = await _eventRepository.fetchEventsForUser(widget.currentUserId);
    setState(() {
      _events = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Event List")),
      body: _events.isEmpty
          ? const Center(child: Text("No events found."))
          : ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return ListTile(
            title: Text(event.name),
            subtitle: Text("Date: ${event.date}\nLocation: ${event.location ?? 'N/A'}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await _eventRepository.deleteEvent(event.id!);
                _fetchEvents();
              },
            ),
          );
        },
      ),
    );
  }
}
