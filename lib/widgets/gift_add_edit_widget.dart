import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/gift_model.dart';
import '../models/event_model.dart';
import '../services/gift_image_cache_service.dart';
import '../services/gift_list_service.dart';
import '../services/publish_event_service.dart';

class GiftAddEditWidget extends StatefulWidget {
  final Gift? gift;
  final List<Event> events;
  final String userId;
  final void Function() onSave;

  const GiftAddEditWidget({
    super.key,
    this.gift,
    required this.events,
    required this.userId,
    required this.onSave,
  });

  @override
  State<GiftAddEditWidget> createState() => _GiftAddEditWidgetState();
}

class _GiftAddEditWidgetState extends State<GiftAddEditWidget> {
  final GiftImageCacheService _giftImageCacheService = GiftImageCacheService();
  final GiftListService _giftService = GiftListService();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;

  String? _base64Image;
  String? _selectedCategory;
  Event? _selectedEvent;

  final List<String> _categories = [
    "Electronics",
    "Books",
    "Toys",
    "Clothing",
    "Appliances",
    "Furniture",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift?.name);
    _descriptionController = TextEditingController(text: widget.gift?.description);
    _priceController = TextEditingController(text: widget.gift?.price?.toString());
    _categoryController = TextEditingController(text: widget.gift?.category);

    _base64Image = widget.gift?.image;
    _selectedCategory = widget.gift?.category ?? _categories.last;

    // Ensure _selectedEvent matches an event from the list or is null
    _selectedEvent = widget.events.firstWhere(
          (event) => event.id == widget.gift?.eventId?.toString(),
      orElse: () => Event(
        id: "0",
        name: "No Event",
        date: "",
        location: "",
        description: "",
        userId: widget.userId,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveGift() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and Price are required.")),
      );
      return;
    }

    // Create the updated gift
    final newGift = Gift(
      id: widget.gift?.id ?? DateTime.now().millisecondsSinceEpoch,
      name: _nameController.text,
      description: _descriptionController.text,
      category: _categoryController.text.isEmpty ? _selectedCategory! : _categoryController.text,
      price: double.parse(_priceController.text),
      status: "Available",
      eventId: int.tryParse(_selectedEvent?.id ?? "0"),
      userId: widget.userId,
      image: _base64Image ?? "",
    );

    try {
      if (widget.gift == null) {
        // Adding a new gift
        await _giftService.addGift(newGift, isPublished: _selectedEvent?.published == 1);
      } else {
        // Editing an existing gift
        final oldEventId = widget.gift!.eventId?.toString();
        final newEventId = newGift.eventId?.toString();

        if (oldEventId != newEventId) {
          // Event ID has changed
          final _publishService = PublishEventService();
          await _publishService.reassignGiftToEvent(
            widget.userId,
            newGift.id.toString(),
            oldEventId ?? "0",
            newEventId ?? "0",
            _selectedEvent?.published == 1,
          );
        }

        // Update other details of the gift locally
        await _giftService.updateGift(newGift, widget.gift!);
      }

      widget.onSave();
      Navigator.pop(context);
    } catch (e) {
      print("Error saving gift: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save gift. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.gift == null ? "Add Gift" : "Edit Gift"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Gift Name"),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedCategory,
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  if (value != "Other") {
                    _categoryController.text = value!;
                  } else {
                    _categoryController.clear();
                  }
                });
              },
            ),
            if (_selectedCategory == "Other")
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: "Enter Custom Category"),
              ),
            DropdownButton<Event>(
              isExpanded: true,
              value: widget.events.contains(_selectedEvent) ? _selectedEvent : null,
              hint: const Text("Assign to Event (Optional)"),
              items: widget.events.map((event) {
                return DropdownMenuItem<Event>(
                  value: event,
                  child: Text(event.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedEvent = value);
              },
            ),
            const SizedBox(height: 10),
            _base64Image?.isEmpty ?? true
                ? TextButton.icon(
              onPressed: () async {
                final updatedImage = await _giftImageCacheService.pickAndResizeImage();
                setState(() => _base64Image = updatedImage);
              },
              icon: const Icon(Icons.image),
              label: const Text("Add Image"),
            )
                : Column(
              children: [
                Image.memory(
                  base64Decode(_base64Image!),
                  height: 100,
                  width: 100,
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _base64Image = null),
                  icon: const Icon(Icons.delete),
                  label: const Text("Remove Image"),
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
          onPressed: _saveGift,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
