import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
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

    try {
      final prefs = await SharedPreferences.getInstance();
      final pledgedGiftIds = prefs.getStringList('pledgedGifts_${widget.currentUserId}') ?? [];

      print("DEBUG: SharedPreferences - Pledged Gift IDs: $pledgedGiftIds");

      // Fetch all "Pledged" gifts from the database
      final allPledgedGifts = await _giftRepository.fetchGiftsByStatus(
        status: 'Pledged',
        userId: widget.currentUserId,
      );

      print("DEBUG: Fetched Gifts: ${allPledgedGifts.map((gift) => gift.toMap()).toList()}");

      // Filter gifts based on SharedPreferences
      final filteredGifts = allPledgedGifts.where((gift) {
        final key = '${gift.userId}|${gift.eventId}|${gift.id}';
        return pledgedGiftIds.contains(key);
      }).toList();

      print("DEBUG: Filtered Pledged Gifts: ${filteredGifts.map((gift) => gift.toMap()).toList()}");

      setState(() {
        _pledgedGifts = filteredGifts;
      });
    } catch (e) {
      print("Error fetching pledged gifts: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _purchaseGift(Gift gift) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'pledgedGifts_${widget.currentUserId}';
      List<String> pledgedGifts = prefs.getStringList(key) ?? [];

      final giftKey = '${gift.userId}|${gift.eventId}|${gift.id}';

      // Ensure it's a pledged gift
      if (!pledgedGifts.contains(giftKey)) {
        throw Exception("Gift is not in pledged status.");
      }

      // Update Firebase
      await FirebaseDatabase.instance
          .ref()
          .child('events/${gift.userId}/${gift.eventId}/gifts/${gift.id}')
          .update({'status': 'Purchased'});

      // Update SQLite
      gift.status = 'Purchased'; // Assuming you update the status directly in SQLite
      await _giftRepository.updateGift(gift);

      // Remove from SharedPreferences
      pledgedGifts.remove(giftKey);
      await prefs.setStringList(key, pledgedGifts);

      // Update local list
      setState(() {
        _pledgedGifts = _pledgedGifts.map((g) {
          if (g.id == gift.id) {
            g.status = 'Purchased';
          }
          return g;
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gift '${gift.name}' marked as Purchased.")),
      );
    } catch (e) {
      print("Error purchasing gift: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to mark gift as Purchased.")),
      );
    }
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
                      trailing: IconButton(
                        icon: Icon(
                          Icons.shopping_cart,
                          color: gift.status == "Purchased"
                              ? Colors.amber
                              : Colors.grey,
                        ),
                        onPressed: gift.status == "Purchased"
                            ? null
                            : () => _purchaseGift(gift),
                        tooltip: gift.status == "Purchased"
                            ? "Already Purchased"
                            : "Mark as Purchased",
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
