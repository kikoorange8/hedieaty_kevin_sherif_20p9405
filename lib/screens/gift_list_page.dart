import 'package:flutter/material.dart';
import '../models/gift_model.dart';
import 'gift_details_page.dart';
import '../repositories/gift_repository.dart';

class GiftListPage extends StatefulWidget {
  final int userId;
  final bool isCurrentUser;

  const GiftListPage({super.key, required this.userId, required this.isCurrentUser});

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
        title: const Text('Gift List'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _gifts.isEmpty
          ? const Center(child: Text('No gifts available.'))
          : ListView.builder(
        itemCount: _gifts.length,
        itemBuilder: (context, index) {
          final gift = _gifts[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: Text(gift.name),
              subtitle: Text(
                'Category: ${gift.category}\nPrice: \$${gift.price.toStringAsFixed(2)}\nStatus: ${gift.status}',
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GiftDetailsPage(
                      gift: gift,
                      isCurrentUser: widget.isCurrentUser, // Pass the `isCurrentUser` flag
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
