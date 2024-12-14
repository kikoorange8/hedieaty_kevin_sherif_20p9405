import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../repositories/event_repository.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

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

    // Fetch all events for the current user
    final events = await _eventRepository.fetchEventsForUser(1); // Current user ID
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  Future<void> _addEvent() async {
    // Example: Show dialog to add a new event
    final nameController = TextEditingController();
    final dateController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Event Date (YYYY-MM-DD)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newEvent = Event(
                  name: nameController.text,
                  date: dateController.text,
                  userId: 1, // Current user ID
                );
                await _eventRepository.addEvent(newEvent);
                Navigator.pop(context);
                await _fetchEvents();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editEvent(Event event) async {
    final nameController = TextEditingController(text: event.name);
    final dateController = TextEditingController(text: event.date);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Event Date (YYYY-MM-DD)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedEvent = Event(
                  id: event.id,
                  name: nameController.text,
                  date: dateController.text,
                  userId: event.userId,
                );
                await _eventRepository.updateEvent(updatedEvent);
                Navigator.pop(context);
                await _fetchEvents();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEvent(int id) async {
    await _eventRepository.deleteEvent(id);
    await _fetchEvents();
  }

  void _sortEventsByName() {
    setState(() {
      _events.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_by_alpha),
            onPressed: _sortEventsByName,
          ),
        ],
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
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(event.name),
              subtitle: Text("Date: ${event.date}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editEvent(event),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteEvent(event.id!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
