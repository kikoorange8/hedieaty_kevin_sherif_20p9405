import 'package:flutter/material.dart';
import '../models/gift_model.dart';
import '../services/gift_list_service.dart';

class GiftDetailsPage extends StatefulWidget {
  final String currentUserId;
  final Gift? gift;

  const GiftDetailsPage({super.key, required this.currentUserId, this.gift});

  @override
  State<GiftDetailsPage> createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final GiftListService _giftService = GiftListService();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;

  bool _isPledged = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift?.name ?? '');
    _descriptionController = TextEditingController(text: widget.gift?.description ?? '');
    _categoryController = TextEditingController(text: widget.gift?.category ?? '');
    _priceController = TextEditingController(text: widget.gift?.price.toString() ?? '');
    _isPledged = widget.gift?.status == "Pledged";
  }

  void _saveGift() async {
    final newGift = Gift(
      id: widget.gift?.id,
      name: _nameController.text,
      description: _descriptionController.text,
      category: _categoryController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      status: _isPledged ? "Pledged" : "Available",
      userId: widget.currentUserId,
    );

    if (widget.gift == null) {
      await _giftService.addGift(newGift);
    } else {
      await _giftService.updateGift(newGift);
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gift == null ? "Add Gift" : "Edit Gift"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
              controller: _categoryController,
              decoration: const InputDecoration(labelText: "Category"),
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),
            SwitchListTile(
              title: const Text("Pledged"),
              value: _isPledged,
              onChanged: widget.gift?.status == "Pledged"
                  ? null
                  : (value) {
                setState(() {
                  _isPledged = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveGift,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
