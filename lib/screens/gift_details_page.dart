import 'dart:convert';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../services/gift_image_cache_service.dart';

class GiftDetailsPage extends StatefulWidget {
  final String giftId;

  const GiftDetailsPage({super.key, required this.giftId});

  @override
  State<GiftDetailsPage> createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final GiftImageCacheService _imageService = GiftImageCacheService();

  Map<String, dynamic>? _giftDetails;

  @override
  void initState() {
    super.initState();
    _loadGiftDetails();
  }

  Future<void> _loadGiftDetails() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'gifts',
        where: 'id = ?',
        whereArgs: [widget.giftId],
      );
      if (result.isNotEmpty) {
        setState(() {
          _giftDetails = result.first;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gift not found.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading gift details: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gift Details"),
        backgroundColor: Colors.indigo,
      ),
      body: _giftDetails == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display Gift Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo, width: 2),
              ),
              child: _giftDetails!['image'] != null &&
                  _giftDetails!['image'].isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(_giftDetails!['image']),
                  fit: BoxFit.cover,
                ),
              )
                  : Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 100,
                  color: Colors.indigo,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Display Gift Name
            Text(
              _giftDetails!['name'] ?? "Unnamed Gift",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),

            // Display Gift Description
            Text(
              _giftDetails!['description'] ?? "No description provided.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // Display Gift Price
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.attach_money, color: Colors.indigo),
                Text(
                  "${_giftDetails!['price'] ?? '0.00'}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Display Gift Category
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.category, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  _giftDetails!['category'] ?? "No category",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Display Gift Status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  _giftDetails!['status'] ?? "Available",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}