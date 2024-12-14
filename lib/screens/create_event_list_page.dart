import 'package:flutter/material.dart';
import '../repositories/event_repository.dart';
import '../repositories/gift_repository.dart';
import '../models/event_model.dart';
import '../models/gift_model.dart';

class CreateEventListPage extends StatefulWidget {
  const CreateEventListPage({super.key});

  @override
  State<CreateEventListPage> createState() => _CreateEventListPageState();
}

class _CreateEventListPageState extends State<CreateEventListPage> {
  final EventRepository _eventRepository = EventRepository();
  final GiftRepository _giftRepository = GiftRepository();

  // Controllers for event form
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventLocationController = TextEditingController();
  DateTime? _selectedEventDate;

  // Controllers for gift form
  final TextEditingController _giftNameController = TextEditingController();
  final TextEditingController _giftDescriptionController = TextEditingController();
  final TextEditingController _giftCategoryController = TextEditingController();
  final TextEditingController _giftPriceController = TextEditingController();
  int? _selectedEventId;

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
      userId: 1, // Replace with the current user's ID
    );
    await _eventRepository.addEvent(newEvent);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Event created successfully!")),
    );
    Navigator.pop(context); // Return to the previous page
  }

  Future<void> _createGift() async {
    if (_giftNameController.text.isEmpty || _selectedEventId == null) {
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
      eventId: _selectedEventId!,
    );
    await _giftRepository.addGift(newGift);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Gift added successfully!")),
    );

    Navigator.pop(context); // Return to the previous page
  }

  Future<void> _selectEventDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    setState(() {
      _selectedEventDate = pickedDate;
    });
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _eventNameController,
                decoration: const InputDecoration(labelText: "Event Name"),
              ),
              TextField(
                controller: _eventLocationController,
                decoration: const InputDecoration(labelText: "Location"),
              ),
              const SizedBox(height: 8),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _giftNameController,
                decoration: const InputDecoration(labelText: "Gift Name"),
              ),
              TextField(
                controller: _giftDescriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextField(
                controller: _giftCategoryController,
                decoration: const InputDecoration(labelText: "Category"),
              ),
              TextField(
                controller: _giftPriceController,
                decoration: const InputDecoration(labelText: "Price"),
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
