import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    // Fetch pledged gifts from the database
    final dbPledgedGifts = await _giftRepository.fetchGiftsByStatus(
      status: "Pledged",
      userId: widget.currentUserId,
    );

    // Fetch pledged gift IDs from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final key = 'pledgedGifts_${widget.currentUserId}';
    final pledgedGiftIds = prefs.getStringList(key) ?? [];

    // Filter database gifts to only include those pledged locally
    final localPledgedGifts = dbPledgedGifts.where((gift) {
      return pledgedGiftIds.contains('${gift.eventId}|${gift.id}');
    }).toList();

    setState(() {
      _pledgedGifts = localPledgedGifts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pledged Gifts"),
        backgroundColor: Colors.indigo,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pledgedGifts.isEmpty
          ? const Center(
        child: Text(
          "No pledged gifts available.",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Pledged Gifts",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _pledgedGifts.length,
                itemBuilder: (context, index) {
                  final gift = _pledgedGifts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        radius: 30,
                        child: Icon(
                          Icons.card_giftcard,
                          size: 30,
                          color: Colors.indigo,
                        ),
                      ),
                      title: Text(
                        gift.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        "Category: ${gift.category}\nPrice: \$${gift.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      trailing: Text(
                        gift.status,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: gift.status == "Pledged"
                              ? Colors.blue
                              : gift.status == "Purchased"
                              ? Colors.amber
                              : Colors.green,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
