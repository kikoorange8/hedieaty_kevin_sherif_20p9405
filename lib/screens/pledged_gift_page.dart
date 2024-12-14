import 'package:flutter/material.dart';
import '../repositories/gift_repository.dart';
import '../models/gift_model.dart';

class PledgedGiftPage extends StatefulWidget {
  final int currentUserId;

  const PledgedGiftPage({super.key, required this.currentUserId});

  @override
  State<PledgedGiftPage> createState() => _PledgedGiftPageState();
}

class _PledgedGiftPageState extends State<PledgedGiftPage> {
  final GiftRepository _giftRepository = GiftRepository();
  bool _isLoading = true; // Tracks loading state
  List<Gift> _pledgedGifts = []; // Holds pledged gifts

  @override
  void initState() {
    super.initState();
    _fetchPledgedGifts(); // Fetch pledged gifts when the page initializes
  }

  Future<void> _fetchPledgedGifts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch pledged gifts for the current user
      final pledgedGifts = await _giftRepository.fetchGiftsByStatus(
        status: "Pledged",
        userId: widget.currentUserId,
      );
      setState(() {
        _pledgedGifts = pledgedGifts;
      });
    } catch (e) {
      // Handle errors (optional)
      print("Error fetching pledged gifts: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pledged Gifts'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pledgedGifts.isEmpty
          ? const Center(
        child: Text(
          'No pledged gifts available.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = _pledgedGifts[index];
          return Card(
            margin: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 16,
            ),
            child: ListTile(
              leading: const Icon(Icons.card_giftcard, size: 40),
              title: Text(gift.name),
              subtitle: Text(
                'Category: ${gift.category}\nPrice: \$${gift.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14),
              ),
              trailing: Text(
                gift.status,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
