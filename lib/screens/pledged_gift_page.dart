import 'package:flutter/material.dart';
import '../repositories/gift_repository.dart';
import '../models/gift_model.dart';

class PledgedGiftPage extends StatefulWidget {
  final String currentUserId;

  const PledgedGiftPage({super.key, required this.currentUserId});

  @override
  State<PledgedGiftPage> createState() => _PledgedGiftPageState();
}

class _PledgedGiftPageState extends State<PledgedGiftPage> {
  final GiftRepository _giftRepository = GiftRepository();
  List<Gift> _pledgedGifts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPledgedGifts();
  }

  Future<void> _fetchPledgedGifts() async {
    setState(() {
      _isLoading = true;
    });

    final pledgedGifts = await _giftRepository.fetchGiftsByStatus(
      status: "Pledged",
      userId: widget.currentUserId,
    );

    setState(() {
      _pledgedGifts = pledgedGifts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pledged Gifts")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pledgedGifts.isEmpty
          ? const Center(child: Text("No pledged gifts available."))
          : ListView.builder(
        itemCount: _pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = _pledgedGifts[index];
          return ListTile(
            title: Text(gift.name),
            subtitle: Text("Category: ${gift.category}\nPrice: \$${gift.price.toStringAsFixed(2)}"),
            trailing: Text(
              gift.status,
              style: TextStyle(color: gift.status == "Pledged" ? Colors.green : Colors.orange),
            ),
          );
        },
      ),
    );
  }
}
