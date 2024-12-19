import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hedieaty_kevin_sherif_20p9405/widgets/gift_add_edit_widget.dart';
import '../models/gift_model.dart';
import '../models/event_model.dart';
import '../services/gift_list_service.dart';
import '../repositories/event_repository.dart';

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
  List<Event> _events = [];
  String _sortCriteria = "name";
  Event? _selectedEvent;

  @override
  void initState() {
    super.initState();
    _loadGifts();
    _loadEvents();
  }

  Future<void> _loadGifts() async {
    setState(() => _isLoading = true);
    try {
      final gifts = await _giftService.getAllGifts(widget.currentUserId);
      setState(() => _gifts = gifts);
    } catch (e) {
      print("Error loading gifts: $e");
      setState(() => _gifts = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _eventRepository.fetchEventsForUser(widget.currentUserId); // Use the existing method
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
        _gifts = _gifts.where((gift) => gift.eventId == int.tryParse(event.id)).toList();
      } else {
        _loadGifts(); // Reload all gifts if no event is selected
      }
    });
  }

  void _showAddEditDialog({Gift? gift}) {
    showDialog(
      context: context,
      builder: (context) => GiftAddEditWidget(
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _sortCriteria,
              items: const [
                DropdownMenuItem(value: "name", child: Text("Sort by Name")),
                DropdownMenuItem(value: "status", child: Text("Sort by Status")),
                DropdownMenuItem(value: "event", child: Text("Sort by Event")),
                DropdownMenuItem(value: "pledged", child: Text("Sort by Pledged")),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<Event?>(
              value: _selectedEvent,
              hint: const Text("Filter by Event"),
              items: [
                const DropdownMenuItem<Event?>(
                  value: null,
                  child: Text("All Events"),
                ),
                ..._events.map((event) {
                  return DropdownMenuItem<Event?>(
                    value: event,
                    child: Text(event.name),
                  );
                }).toList(),
              ],
              onChanged: _filterGiftsByEvent,
            ),
          ),
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
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: gift.image?.isNotEmpty == true
                          ? Image.memory(
                        base64Decode(gift.image!),
                        height: 64,
                        width: 64,
                        fit: BoxFit.cover,
                      )
                          : const Icon(Icons.card_giftcard, size: 64),
                    ),
                    title: Text(gift.name),
                    subtitle: Text(
                      "Category: ${gift.category}\nPrice: \$${gift.price}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: gift.status == "Pledged" ? Colors.grey : Colors.blue,
                          ),
                          onPressed: gift.status == "Pledged"
                              ? null
                              : () => _showAddEditDialog(gift: gift),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: gift.status == "Pledged" ? Colors.grey : Colors.red,
                          ),
                          onPressed: gift.status == "Pledged"
                              ? null
                              : () async {
                            await _giftService.deleteGift(gift.id);
                            _loadGifts();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
