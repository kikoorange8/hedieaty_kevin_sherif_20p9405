import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hedieaty_kevin_sherif_20p9405/widgets/gift_add_edit_widget.dart';
import '../models/gift_model.dart';
import '../models/event_model.dart';
import '../services/gift_list_service.dart';
import '../repositories/event_repository.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';

class GiftListPage extends StatefulWidget {
  final String currentUserId;

  const GiftListPage({
    super.key,
    required this.currentUserId,
  });

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final GiftListService _giftService = GiftListService();
  final EventRepository _eventRepository = EventRepository(); // Instantiate EventRepository

  bool _isLoading = true;
  List<Gift> _gifts = [];
  List<Gift> _allGifts = []; // New list to store all gifts
  List<Event> _events = [];
  String _sortCriteria = "name";
  Event? _selectedEvent;

  @override
  void initState() {
    super.initState();
    _loadGifts();
    _loadEvents();
  }

  Future<String> _getEventNameFromSql(int? eventId) async {
    if (eventId == null || eventId == 0) {
      return ""; // No event assigned
    }
    try {
      final event = await _eventRepository.getEventById(eventId.toString());
      return event?.name ?? ""; // Return the event name or empty string if not found
    } catch (e) {
      print("Error fetching event name from SQL: $e");
      return ""; // Default to empty on error
    }
  }

  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadGifts() async {
    setState(() => _isLoading = true);
    try {
      final gifts = await _giftService.getAllGifts(widget.currentUserId);
      setState(() {
        _allGifts = gifts; // Store all gifts
        _gifts = List.from(_allGifts); // Initially show all gifts
      });
      print("Loaded Gifts: $_allGifts");
    } catch (e) {
      print("Error loading gifts: $e");
      setState(() {
        _allGifts = [];
        _gifts = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _getEventNameFromRepository(int? eventId) async {
    if (eventId == null) return "No Event";
    try {
      final events = await _eventRepository.fetchEventsForUser(
          widget.currentUserId);
      final event = events.firstWhere(
            (e) => e.id == eventId.toString(),
        orElse: () =>
            Event(id: "0",
                name: "No Event",
                date: "",
                location: "",
                description: "",
                userId: ""),
      );
      return event.name;
    } catch (e) {
      print("Error fetching event name: $e");
      return "No Event";
    }
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _eventRepository.fetchEventsForUser(
          widget.currentUserId); // Use the existing method
      setState(() => _events = events);
    } catch (e) {
      print("Error loading events: $e");
    }
  }

  void _sortGifts() {
    setState(() {
      if (_sortCriteria == "name") {
        _gifts.sort((a, b) => a.name.compareTo(b.name));
      } else if (_sortCriteria == "status") {
        _gifts.sort((a, b) => a.status.compareTo(b.status));
      } else if (_sortCriteria == "event") {
        _gifts.sort((a, b) => (a.eventId ?? 0).compareTo(b.eventId ?? 0));
      } else if (_sortCriteria == "pledged") {
        _gifts.sort((a, b) => a.status == "Pledged" ? -1 : 1);
      }
    });
  }

  void _filterGiftsByEvent(Event? event) {
    setState(() {
      _selectedEvent = event;
      if (event != null) {
        print("Filtering by Event: ${event.id}");
        print("All Gifts: $_allGifts");

        _gifts = _allGifts.where((gift) {
          print("Gift ID: ${gift.id}, Gift Event ID: ${gift.eventId}");
          return gift.eventId == int.tryParse(event.id);
        }).toList();

        print("Filtered Gifts: $_gifts");
      } else {
        print("No Event Selected, Showing All Gifts");
        _gifts = List.from(_allGifts);
      }
    });
  }

  Future<bool> checkGiftPledgedOrPurchased(String currentUserId, String eventId, String giftId) async {
    try {
      final dbRef = FirebaseDatabase.instance.ref();
      final giftSnapshot = await dbRef.child(
          'events/$currentUserId/$eventId/gifts/$giftId/status').get();

      if (giftSnapshot.exists) {
        final status = giftSnapshot.value.toString();
        if (status == "Pledged" || status == "Purchased") {
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Error checking gift status: $e");
      return false; // Assume editable if there's an error
    }
  }

  void _showAddEditDialog({Gift? gift}) {
    showDialog(
      context: context,
      builder: (context) =>
          GiftAddEditWidget(
            gift: gift,
            events: _events,
            userId: widget.currentUserId,
            onSave: _loadGifts,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gift List"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // Sort Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0),
            child: DropdownButtonFormField<String>(
              value: _sortCriteria,
              decoration: InputDecoration(
                labelText: "Sort Gifts",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.teal.shade50,
              ),
              items: const [
                DropdownMenuItem(value: "name", child: Text("Sort by Name")),
                DropdownMenuItem(
                    value: "status", child: Text("Sort by Status")),
                DropdownMenuItem(
                    value: "pledged", child: Text("Sort by Pledged")),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _sortCriteria = value;
                    _sortGifts();
                  });
                }
              },
            ),
          ),

          // Filter Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 8.0),
            child: DropdownButtonFormField<Event?>(
              value: _selectedEvent,
              decoration: InputDecoration(
                labelText: "Filter by Event",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.teal.shade50,
              ),
              items: [
                const DropdownMenuItem<Event?>(
                    value: null, child: Text("All Events")),
                ..._events.map((event) {
                  return DropdownMenuItem<Event?>(
                      value: event, child: Text(event.name));
                }).toList(),
              ],
              onChanged: _filterGiftsByEvent,
            ),
          ),

          // Gifts List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _gifts.isEmpty
                ? const Center(
              child: Text(
                "No gifts available.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
                : ListView.builder(
              itemCount: _gifts.length,
              itemBuilder: (context, index) {
                final gift = _gifts[index];
                return FutureBuilder<bool>(
                  future: checkGiftPledgedOrPurchased(
                      widget.currentUserId, gift.eventId.toString(), gift.id.toString()),
                  builder: (context, snapshot) {
                    final isPledgedOrPurchased = snapshot.data ?? false;

                    return FutureBuilder<String>(
                      future: _getEventNameFromSql(gift.eventId),
                      builder: (context, eventSnapshot) {
                        final eventName = eventSnapshot.data ?? ""; // Default to empty if no event name
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: gift.image?.isNotEmpty == true
                                  ? Image.memory(
                                base64Decode(gift.image!),
                                height: 64,
                                width: 64,
                                fit: BoxFit.cover,
                              )
                                  : const Icon(Icons.card_giftcard,
                                  size: 64, color: Colors.teal),
                            ),
                            title: Text(
                              gift.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Category: ${gift.category}\nPrice: \$${gift.price}" +
                                  (eventName.isNotEmpty
                                      ? "\nEvent: $eventName"
                                      : ""), // Add event name only if it exists
                              style: const TextStyle(color: Colors.black54),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Edit Button
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: isPledgedOrPurchased ? Colors.grey : Colors.blue,
                                  ),
                                  onPressed: () {
                                    if (isPledgedOrPurchased) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Cannot edit a pledged or purchased gift."),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      return;
                                    }
                                    _showAddEditDialog(gift: gift);
                                  },
                                ),
                                // Delete Button
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: isPledgedOrPurchased ? Colors.grey : Colors.red,
                                  ),
                                  onPressed: () async {
                                    if (isPledgedOrPurchased) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Cannot delete a pledged or purchased gift."),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      return;
                                    }
                                    await _giftService.deleteGift(gift.id);
                                    _loadGifts();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },





            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}