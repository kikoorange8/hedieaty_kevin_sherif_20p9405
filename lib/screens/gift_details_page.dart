import 'package:flutter/material.dart';
import '../models/gift_model.dart';
import '../repositories/gift_repository.dart';

class GiftDetailsPage extends StatefulWidget {
  final Gift gift; // The gift being viewed
  final bool isCurrentUser; // Indicates if the gift belongs to the current user

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

  Future<void> _pledgeGift() async {
    if (widget.gift.status == "Available") {
      final updatedGift = Gift(
        id: widget.gift.id,
        name: widget.gift.name,
        description: widget.gift.description,
        category: widget.gift.category,
        price: widget.gift.price,
        status: "Pledged",
        eventId: widget.gift.eventId,
      );
      await _giftRepository.updateGift(updatedGift);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gift pledged successfully!")),
      );
      setState(() {
        widget.gift.status = "Pledged"; // Update UI to reflect change
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This gift is already pledged.")),
      );
    }
  }

  Future<void> _editGift() async {
    final nameController = TextEditingController(text: widget.gift.name);
    final descriptionController = TextEditingController(text: widget.gift.description);
    final categoryController = TextEditingController(text: widget.gift.category);
    final priceController = TextEditingController(text: widget.gift.price.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Gift"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
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
                final updatedGift = Gift(
                  id: widget.gift.id,
                  name: nameController.text,
                  description: descriptionController.text,
                  category: categoryController.text,
                  price: double.parse(priceController.text),
                  status: widget.gift.status,
                  eventId: widget.gift.eventId,
                );
                await _giftRepository.updateGift(updatedGift);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Gift updated successfully!")),
                );
                setState(() {
                  widget.gift.name = updatedGift.name;
                  widget.gift.description = updatedGift.description;
                  widget.gift.category = updatedGift.category;
                  widget.gift.price = updatedGift.price;
                });
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
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
            Text(
              widget.gift.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.gift.description,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              "Category: ${widget.gift.category}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Price: \$${widget.gift.price.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Status: ${widget.gift.status}",
              style: TextStyle(
                fontSize: 16,
                color: widget.gift.status == "Pledged"
                    ? Colors.orange
                    : Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            if (!widget.isCurrentUser)
              ElevatedButton(
                onPressed: _pledgeGift,
                child: const Text("Pledge Gift"),
              ),
            if (widget.isCurrentUser)
              ElevatedButton(
                onPressed: _editGift,
                child: const Text("Edit Gift"),
              ),
          ],
        ),
      ),
    );
  }
}
