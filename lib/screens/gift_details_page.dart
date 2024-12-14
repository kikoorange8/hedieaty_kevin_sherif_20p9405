import 'package:flutter/material.dart';
import '../models/gift_model.dart';
import '../repositories/gift_repository.dart';

class GiftDetailsPage extends StatefulWidget {
  final Gift gift;
  final bool isCurrentUser;

  const GiftDetailsPage({
    super.key,
    required this.gift,
    required this.isCurrentUser,
  });

  @override
  State<GiftDetailsPage> createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final GiftRepository _giftRepository = GiftRepository();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers with existing gift details
    _nameController.text = widget.gift.name;
    _descriptionController.text = widget.gift.description;
    _categoryController.text = widget.gift.category;
    _priceController.text = widget.gift.price.toString();
  }

  Future<void> _pledgeGift() async {
    if (widget.gift.status == "Pledged") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This gift is already pledged!")),
      );
      return;
    }

    final updatedGift = Gift(
      id: widget.gift.id,
      name: widget.gift.name,
      description: widget.gift.description,
      category: widget.gift.category,
      price: widget.gift.price,
      status: "Pledged", // Update status to pledged
      eventId: widget.gift.eventId,
      userId: widget.gift.userId,
    );

    await _giftRepository.updateGift(updatedGift);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Gift pledged successfully!")),
    );

    setState(() {
      // Refresh the UI
    });
  }

  Future<void> _updateGift() async {
    final updatedGift = Gift(
      id: widget.gift.id,
      name: _nameController.text,
      description: _descriptionController.text,
      category: _categoryController.text,
      price: double.tryParse(_priceController.text) ?? widget.gift.price,
      status: widget.gift.status, // Keep the existing status
      eventId: widget.gift.eventId,
      userId: widget.gift.userId,
    );

    await _giftRepository.updateGift(updatedGift);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Gift updated successfully!")),
    );

    setState(() {
      // Update the UI
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gift Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Gift Name"),
              enabled: widget.isCurrentUser,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Gift Description"),
              enabled: widget.isCurrentUser,
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: "Gift Category"),
              enabled: widget.isCurrentUser,
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: "Gift Price"),
              keyboardType: TextInputType.number,
              enabled: widget.isCurrentUser,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.isCurrentUser ? _updateGift : _pledgeGift,
              child: Text(widget.isCurrentUser ? "Update Gift" : "Pledge Gift"),
            ),
          ],
        ),
      ),
    );
  }
}
