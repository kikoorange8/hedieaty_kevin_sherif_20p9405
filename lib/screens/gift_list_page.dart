import 'package:flutter/material.dart';
import '../models/gift_model.dart';
import '../repositories/gift_repository.dart';

class GiftListPage extends StatefulWidget {
  final int userId; // The user ID to fetch gifts for
  final bool isCurrentUser; // Indicates if this page is for the current user

  const GiftListPage({
    super.key,
    required this.userId,
    this.isCurrentUser = false, // Defaults to false for friends' gifts
  });

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final GiftRepository _giftRepository = GiftRepository();
  List<Gift> _gifts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _addSampleGifts(); // Add sample gifts for testing
    _fetchGifts();
  }

  Future<void> _addSampleGifts() async {
    // Add sample gifts for testing
    final sampleGifts = [
      Gift(
        name: "Laptop",
        description: "A high-performance laptop.",
        category: "Electronics",
        price: 1200.00,
        status: "Available",
        eventId: 1, // Assume event ID 1 exists in the database
      ),
      Gift(
        name: "Smartphone",
        description: "The latest smartphone model.",
        category: "Electronics",
        price: 800.00,
        status: "Pledged",
        eventId: 1, // Same event ID as above
      ),
      Gift(
        name: "Book",
        description: "A best-selling novel.",
        category: "Books",
        price: 20.00,
        status: "Available",
        eventId: 2, // Assume event ID 2 exists in the database
      ),
    ];

    for (var gift in sampleGifts) {
      await _giftRepository.addGift(gift);
    }
    print("Sample gifts added for testing.");
  }

  Future<void> _fetchGifts() async {
    setState(() {
      _isLoading = true;
    });

    // Fetch all gifts for the user or friend's events
    final gifts = await _giftRepository.fetchGiftsForUser(widget.userId);
    setState(() {
      _gifts = gifts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isCurrentUser ? 'My Gifts' : "Friend's Gifts",
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _gifts.isEmpty
          ? const Center(
        child: Text(
          'No gifts available.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _gifts.length,
        itemBuilder: (context, index) {
          final gift = _gifts[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.card_giftcard, size: 40),
              title: Text(gift.name),
              subtitle: Text(
                '${gift.description}\nCategory: ${gift.category}\nPrice: \$${gift.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14),
              ),
              trailing: Text(
                gift.status, // Status (e.g., Available, Pledged, Purchased)
                style: TextStyle(
                  fontSize: 14,
                  color: gift.status == 'Pledged'
                      ? Colors.orange
                      : gift.status == 'Purchased'
                      ? Colors.green
                      : Colors.blue,
                ),
              ),
              onTap: () {
                print('Tapped on gift: ${gift.name}');
                // Navigate to gift details if needed
              },
            ),
          );
        },
      ),
    );
  }
}
