import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/gift_model.dart';
import '../services/publish_event_service.dart';
import '../repositories/event_repository.dart';
import '../models/event_model.dart';
import '../repositories/gift_repository.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';

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

  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasPledgedGifts(String userId, String eventId) async {
    final DatabaseReference eventRef = FirebaseDatabase.instance.ref('events/$userId/$eventId/gifts');

    try {
      // Fetch data from Firebase
      final snapshot = await eventRef.get();
      print("Snapshot fetched for userId $userId, eventId $eventId: ${snapshot.value}");

      if (snapshot.exists) {
        final gifts = snapshot.value as Map<dynamic, dynamic>;
        print("Gifts for userId $userId, eventId $eventId: $gifts");

        // Check each gift for "Pledged" status
        for (var giftKey in gifts.keys) {
          final gift = gifts[giftKey];
          print("Gift ID: $giftKey, Data: $gift");

          if (gift['status'] == 'Pledged') {
            print("Gift with ID $giftKey is pledged.");
            return true; // Found a pledged gift
          }
        }
      } else {
        print("No gifts found for userId $userId, eventId $eventId.");
      }
    } catch (e) {
      print("Error checking pledged gifts for userId $userId, eventId $eventId: $e");
    }

    print("No pledged gifts found for userId $userId, eventId $eventId.");
    return false; // No pledged gifts found
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
    if (event.published == 1) {
      // Check for internet connection
      final isConnected = await checkInternetConnection();
      if (!isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You must be connected to the internet to edit published events.")),
        );
        return;
      }else{
        print("has internet connection and published check if it has pledged gifts");
        final hasPledged = await hasPledgedGifts(widget.currentUserId, event.id);
        if (hasPledged) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cannot edit or delete an event with pledged gifts.")),
          );
          return;
        }
      }
    }

    // Proceed with the edit logic
    final TextEditingController nameController = TextEditingController(text: event.name);
    final TextEditingController locationController = TextEditingController(text: event.location);
    final TextEditingController descriptionController = TextEditingController(text: event.description);
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
        backgroundColor: Colors.teal,
        actions: [
          _buildSortOptions(), // Dropdown for sorting options
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _events.isEmpty
          ? const Center(
        child: Text(
          "No events found.",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          final status = _getEventStatus(event.date);
          final statusColor = _getEventStatusColor(status);

          return Card(
            elevation: 6,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => _editEvent(event),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon for event status
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(5),
                      ),

                      child: Icon(
                        Icons.edit,
                        color: statusColor,
                        size: 15,
                      ),


                    ),
                    const SizedBox(width: 12),
                    // Event details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Date: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(event.date))}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Location: ${event.location}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Published: ${event.published == 1 ? "Yes" : "No"}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color:
                              event.published == 1 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Publish/unpublish action
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        IconButton(
                          icon: Icon(
                            Icons.cloud_upload,
                            size: 28,
                            color: event.published == 1 ? Colors.blue : Colors.grey,
                          ),
                          onPressed: () async {
                            if (event.published == 1) {
                              // Check for internet connection before unpublishing
                              final isConnected = await checkInternetConnection();
                              if (!isConnected) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "You need to be connected to the internet to unpublish this event."),
                                  ),
                                );
                                return;
                              }

                              // Check if the event has pledged gifts
                              final hasPledged = await hasPledgedGifts(
                                  widget.currentUserId, event.id);
                              if (hasPledged) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Cannot unpublish this event because it has pledged gifts."),
                                  ),
                                );
                                return;
                              }

                              // Unpublish the event
                              await _publishService.unpublishEvent(event);
                            } else {
                              // Check for internet connection before publishing
                              final isConnected = await checkInternetConnection();
                              if (!isConnected) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "You need to be connected to the internet to publish this event."),
                                  ),
                                );
                                return;
                              }

                              // Publish the event
                              await _publishService.publishEvent(event);

                              // Add gifts for the published event to Firebase
                              await _publishService.addGiftsForEvent(
                                  widget.currentUserId, event.id);
                            }

                            // Reload events to update UI
                            _loadEvents();
                          },
                          tooltip: event.published == 1
                              ? "Unpublish Event"
                              : "Publish to Cloud",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createEvent,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}