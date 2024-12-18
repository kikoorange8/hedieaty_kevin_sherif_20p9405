import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // Load events from SQLite
  Future<void> _loadEvents() async {
    final events = await _eventRepository.fetchEventsForUser(widget.currentUserId);
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  // Determine if the event is Upcoming, Current, or Passed
  String _getEventStatus(String date) {
    final eventDate = DateTime.parse(date);
    final currentDate = DateTime.now();

    if (eventDate.isAfter(currentDate)) return "Upcoming";
    if (eventDate.year == currentDate.year &&
        eventDate.month == currentDate.month &&
        eventDate.day == currentDate.day) {
      return "Current";
    }
    return "Passed";
  }

  // Publish Event to Firebase
  Future<void> _publishEvent(Event event) async {
    try {
      await _eventRepository.publishEvent(event);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Event '${event.name}' published successfully!")),
      );
      _loadEvents();
    } catch (e) {
      print("Error publishing event: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to publish event.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event List"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
          ? const Center(child: Text("No events found."))
          : ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          final status = _getEventStatus(event.date);

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(event.name),
              subtitle: Text(
                "Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(event.date))}\n"
                    "Location: ${event.location}\n"
                    "Status: $status\n"
                    "Published: ${event.published == 1 ? 'Yes' : 'No'}",
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.cloud_upload,
                  color: event.published == 1 ? Colors.grey : Colors.blue,
                ),
                onPressed: event.published == 1
                    ? null // Disable button if already published
                    : () => _publishEvent(event),
                tooltip: event.published == 1
                    ? "Already Published"
                    : "Publish Event",
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add a new event (keep your existing _createEvent logic)
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
