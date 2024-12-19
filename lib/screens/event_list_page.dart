import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/gift_model.dart';
import '../services/publish_event_service.dart';
import '../repositories/event_repository.dart';
import '../models/event_model.dart';
import '../repositories/gift_repository.dart';


class EventListPage extends StatefulWidget {
  final String currentUserId;

  const EventListPage({super.key, required this.currentUserId});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {

  final EventRepository _eventRepository = EventRepository();
  final PublishEventService _publishService = PublishEventService();

  List<Event> _events = [];
  bool _isLoading = true;
  String _sortBy = 'date'; // Default sort by date

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    final allEvents = await _eventRepository.fetchEventsForUser(widget.currentUserId);

    // Sort events based on the selected sorting criteria
    allEvents.sort((a, b) => _sortEvents(a, b));

    setState(() {
      _events = allEvents;
      _isLoading = false;
    });
  }

  int _sortEvents(Event a, Event b) {
    if (_sortBy == 'date') {
      return DateTime.parse(a.date).compareTo(DateTime.parse(b.date));
    } else if (_sortBy == 'published') {
      return a.published.compareTo(b.published); // Unpublished (0) comes first
    }
    return 0;
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

  Future<void> _createEvent() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Create New Event"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Event Name"),
                    ),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: "Location"),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: "Description (Optional)"),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          selectedDate == null
                              ? "Select Date"
                              : DateFormat('yyyy-MM-dd').format(selectedDate!),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setDialogState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Name and Date are required.")),
                      );
                      return;
                    }

                    final newEvent = Event(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      date: selectedDate!.toIso8601String(),
                      location: locationController.text,
                      description: descriptionController.text,
                      userId: widget.currentUserId,
                      published: 0,
                    );

                    await _publishService.saveEventLocally(newEvent);
                    Navigator.pop(context);
                    _loadEvents();
                  },
                  child: const Text("Create"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _editEvent(Event event) async {
    final TextEditingController nameController = TextEditingController(text: event.name);
    final TextEditingController locationController = TextEditingController(text: event.location);
    final TextEditingController descriptionController =
    TextEditingController(text: event.description);
    DateTime selectedDate = DateTime.parse(event.date);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Event"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Event Name"),
                    ),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: "Location"),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: "Category (Optional)"),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          DateFormat('yyyy-MM-dd').format(selectedDate),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setDialogState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    final editedEvent = event.copyWith(
                      name: nameController.text,
                      location: locationController.text,
                      description: descriptionController.text,
                      date: selectedDate.toIso8601String(),
                    );

                    await _publishService.editEvent(editedEvent);
                    Navigator.pop(context);
                    _loadEvents();
                  },
                  child: const Text("Save Changes"),
                ),
                TextButton(
                  onPressed: () async {
                    await _publishService.deleteEvent(event);
                    Navigator.pop(context);
                    _loadEvents();
                  },
                  child: const Text(
                    "Delete Event",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSortOptions() {
    return DropdownButton<String>(
      value: _sortBy,
      onChanged: (value) {
        setState(() {
          _sortBy = value!;
          _loadEvents();
        });
      },
      items: const [
        DropdownMenuItem(
          value: 'date',
          child: Text("Sort by Date"),
        ),
        DropdownMenuItem(
          value: 'published',
          child: Text("Sort by Published"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event List"),
        actions: [
          _buildSortOptions(), // Dropdown for sorting options
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
          ? const Center(child: Text("No events found."))
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          final status = _getEventStatus(event.date);
          final statusColor = _getEventStatusColor(status);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text(event.name),
              subtitle: Text(
                "Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(event.date))}\n"
                    "Location: ${event.location}\n"
                    "Published: ${event.published == 1 ? "Yes" : "No"}",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.cloud_upload,
                      color: event.published == 1 ? Colors.blue : Colors.grey,
                    ),
                    onPressed: () async {
                      if (event.published == 1) {
                        await _publishService.unpublishEvent(event);
                      } else {
                        await _publishService.publishEvent(event);

                        // Call addGiftsForEvent with the correct userId and eventId
                        await PublishEventService().addGiftsForEvent(widget.currentUserId, event.id);
                      }
                      _loadEvents(); // Reload events to update UI
                    },
                    tooltip: event.published == 1 ? "Unpublish Event" : "Publish to Cloud",
                  ),

                ],
              ),
              onTap: () => _editEvent(event),
            ),
          );
        },
      ),




      floatingActionButton: FloatingActionButton(
        onPressed: _createEvent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
