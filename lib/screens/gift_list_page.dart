import 'package:flutter/material.dart';
import 'package:hedieaty_kevin_sherif_20p9405/screens/gift_details_page.dart';
import '../repositories/gift_repository.dart';
import '../models/gift_model.dart';

class GiftListPage extends StatefulWidget {
  final int userId; // User or friend's ID
  final bool isCurrentUser; // Indicates if this is the current user's gifts

  const GiftListPage({
    super.key,
    required this.userId,
    this.isCurrentUser = false, // Defaults to friend's gifts
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
    _fetchGifts();
  }

  Future<void> _fetchGifts() async {
    setState(() {
      _isLoading = true;
    });

    // Fetch all gifts for the current user or friend's events
    final gifts = await _giftRepository.fetchGiftsForUser(widget.userId);
    setState(() {
      _gifts = gifts;
      _isLoading = false;
    });
  }

  Future<void> _pledgeGift(Gift gift) async {
    if (gift.status == "Available") {
      final updatedGift = Gift(
        id: gift.id,
        name: gift.name,
        description: gift.description,
        category: gift.category,
        price: gift.price,
        status: "Pledged",
        eventId: gift.eventId,
      );
      await _giftRepository.updateGift(updatedGift);
      await _fetchGifts(); // Refresh the list after updating
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gift pledged successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This gift is already pledged.")),
      );
    }
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
                gift.status,
                style: TextStyle(
                  fontSize: 14,
                  color: gift.status == 'Pledged'
                      ? Colors.orange
                      : Colors.blue,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GiftDetailsPage(
                      gift: gift, // Pass the selected gift
                      isCurrentUser: widget.isCurrentUser, // Pass whether this is the current user
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
