import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/event_model.dart';
import '../models/gift_model.dart';
import '../services/gift_list_service.dart';
import '../repositories/event_repository.dart';
import 'package:image/image.dart' as img;
import 'package:collection/collection.dart';


class GiftListPage extends StatefulWidget {
  final String currentUserId;
  final bool isCurrentUser;

  const GiftListPage({
    super.key,
    required this.currentUserId,
    this.isCurrentUser = false,
  });

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final GiftListService _giftService = GiftListService();
  final EventRepository _eventRepository = EventRepository();

  bool _isLoading = true; // Loading flag
  List<Gift> _gifts = []; // List of gifts
  File? _selectedImage;
  String? _base64Image;
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadGifts();
    _fetchEvents();
  }

  Future<void> _loadGifts() async {
    setState(() => _isLoading = true);

    try {
      // Fetch gifts from the service
      final gifts = await _giftService.fetchGifts(widget.currentUserId, "");
      setState(() {
        _gifts = gifts; // Update the gift list
      });
    } catch (e) {
      print("Error loading gifts: $e");
      setState(() {
        _gifts = []; // Ensure _gifts is empty if there's an error
      });
    } finally {
      setState(() => _isLoading = false); // Stop loading indicator
    }
  }


  Future<void> _fetchEvents() async {
    final events = await _eventRepository.fetchEventsForUser(widget.currentUserId);
    setState(() => _events = events);
  }

  Future<void> _editGift(Gift gift) async {
    final nameController = TextEditingController(text: gift.name);
    final descriptionController = TextEditingController(text: gift.description);
    final categoryController = TextEditingController(text: gift.category);
    final priceController = TextEditingController(text: gift.price.toString());
    Event? selectedEvent = _events.firstWhereOrNull((e) => e.id == gift.eventId);



    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Gift"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: "Gift Name")),
                    TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Description")),
                    TextField(controller: categoryController, decoration: const InputDecoration(labelText: "Category")),
                    TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Price")),
                    const SizedBox(height: 10),
                    DropdownButton<Event>(
                      isExpanded: true,
                      value: selectedEvent,
                      hint: const Text("Assign to Event"),
                      items: _events.map((event) {
                        return DropdownMenuItem<Event>(
                          value: event,
                          child: Text(event.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedEvent = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                TextButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || priceController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name and Price are required.")));
                      return;
                    }

                    final updatedGift = Gift(
                      id: gift.id,
                      name: nameController.text,
                      description: descriptionController.text,
                      category: categoryController.text,
                      price: double.parse(priceController.text),
                      status: gift.status,
                      eventId: selectedEvent?.id,
                      userId: widget.currentUserId,
                      image: gift.image,
                    );

                    await _giftService.updateGift(updatedGift);
                    Navigator.pop(context);
                    _loadGifts();
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addGiftDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController();
    Event? selectedEvent;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add New Gift"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: "Gift Name")),
                    TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Description")),
                    TextField(controller: categoryController, decoration: const InputDecoration(labelText: "Category")),
                    TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Price")),
                    DropdownButton<Event>(
                      isExpanded: true,
                      value: selectedEvent,
                      hint: const Text("Assign to Event"),
                      items: _events.map((event) {
                        return DropdownMenuItem<Event>(
                          value: event,
                          child: Text(event.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedEvent = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                TextButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || priceController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Name and Price are required.")));
                      return;
                    }

                    final newGift = Gift(
                      name: nameController.text,
                      description: descriptionController.text,
                      category: categoryController.text,
                      price: double.parse(priceController.text),
                      status: "Not Pledged",
                      eventId: selectedEvent?.id,
                      userId: widget.currentUserId,
                      image: _base64Image ?? "",
                    );

                    await _giftService.addGift(newGift);
                    Navigator.pop(context);
                    _loadGifts();
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gift List")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _gifts.isEmpty
          ? const Center(child: Text("No gifts available.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
          : ListView.builder(
        itemCount: _gifts.length,
        itemBuilder: (context, index) {
          final gift = _gifts[index];
          return Card(
            child: ListTile(
              title: Text(gift.name),
              subtitle: Text("Category: ${gift.category}\nPrice: \$${gift.price}"),
              trailing: Text(gift.eventId != null ? "Assigned" : "Unassigned"),
              onTap: () => _editGift(gift),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addGiftDialog, child: const Icon(Icons.add)),
    );
  }
}
