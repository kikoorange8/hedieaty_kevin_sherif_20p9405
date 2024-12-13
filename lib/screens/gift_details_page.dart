import 'package:flutter/material.dart';

class GiftDetailsPage extends StatelessWidget {
  final String giftName;
  final String description;
  final String category;
  final double price;
  final String status;

  const GiftDetailsPage({
    super.key,
    required this.giftName,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $giftName', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Description: $description'),
            const SizedBox(height: 8),
            Text('Category: $category'),
            const SizedBox(height: 8),
            Text('Price: \$${price.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Status: $status'),
          ],
        ),
      ),
    );
  }
}
