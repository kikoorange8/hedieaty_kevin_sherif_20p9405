import 'package:flutter/material.dart';
import '../repositories/event_repository.dart';
import '../repositories/gift_repository.dart';
import '../models/event_model.dart';
import '../models/gift_model.dart';

class CreateEventListPage extends StatefulWidget {
  final int currentUserId;

  const CreateEventListPage({super.key, required this.currentUserId});

  @override
  State<CreateEventListPage> createState() => _CreateEventListPageState();
}

class _CreateEventListPageState extends State<CreateEventListPage> {
  final EventRepository _eventRepository = EventRepository();
  final GiftRepository _giftRepository = GiftRepository();

  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventLocationController = TextEditingController();
  DateTime? _selectedEventDate;

  final TextEditingController _giftNameController = TextEditingController();
  final TextEditingController _giftDescriptionController = TextEditingController();
  final TextEditingController _giftCategoryController = TextEditingController();
  final TextEditingController _giftPriceController = TextEditingController();

  Future<void> _createEvent() async {
    if (_eventNameController.text.isEmpty || _selectedEventDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields for the event.")),
      );
      return;
    }

    final newEvent = Event(
      name: _eventNameController.text,
      date: _selectedEventDate!.toIso8601String(),
      location: _eventLocationController.text,
      userId: widget.currentUserId, // Set to current user ID
    );

    await _eventRepository.addEvent(newEvent);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Event created successfully!")),
    );

    // Clear event form
    _eventNameController.clear();
    _eventLocationController.clear();
    setState(() {
      _selectedEventDate = null;
    });
  }

  Future<void> _createGift() async {
    if (_giftNameController.text.isEmpty ||
        _giftDescriptionController.text.isEmpty ||
        _giftCategoryController.text.isEmpty ||
        _giftPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields for the gift.")),
      );
      return;
    }

    final newGift = Gift(
      name: _giftNameController.text,
      description: _giftDescriptionController.text,
      category: _giftCategoryController.text,
      price: double.tryParse(_giftPriceController.text) ?? 0.0,
      status: "Available",
      eventId: null, // Assume not associated with an event
      userId: widget.currentUserId, // Pass the currentUserId
    );

    await _giftRepository.addGift(newGift);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Gift created successfully!")),
    );

    // Clear gift form
    _giftNameController.clear();
    _giftDescriptionController.clear();
    _giftCategoryController.clear();
    _giftPriceController.clear();
  }

  Future<void> _selectEventDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedEventDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Event/List"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create Event",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: "Event Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _eventLocationController,
                decoration: const InputDecoration(
                  labelText: "Event Location",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _selectEventDate,
                    child: const Text("Pick Event Date"),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _selectedEventDate != null
                        ? _selectedEventDate!.toLocal().toString().split(' ')[0]
                        : "No Date Selected",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _createEvent,
                child: const Text("Save Event"),
              ),
              const Divider(height: 32),
              const Text(
                "Create Gift",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _giftNameController,
                decoration: const InputDecoration(
                  labelText: "Gift Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _giftDescriptionController,
                decoration: const InputDecoration(
                  labelText: "Gift Description",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _giftCategoryController,
                decoration: const InputDecoration(
                  labelText: "Gift Category",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _giftPriceController,
                decoration: const InputDecoration(
                  labelText: "Gift Price",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _createGift,
                child: const Text("Save Gift"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
