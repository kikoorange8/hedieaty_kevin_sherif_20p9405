import 'package:flutter/material.dart';
import '../repositories/gift_repository.dart';
import '../models/gift_model.dart';

class GiftListPage extends StatefulWidget {
  final String userId;
  final bool isCurrentUser;

  const GiftListPage({super.key, required this.userId, required this.isCurrentUser});

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final GiftRepository _giftRepository = GiftRepository();
  List<Gift> _gifts = [];

  @override
  void initState() {
    super.initState();
    _fetchGifts();
  }

  Future<void> _fetchGifts() async {
    final gifts = await _giftRepository.fetchGiftsForUser(widget.userId);
    setState(() {
      _gifts = gifts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gift List")),
      body: _gifts.isEmpty
          ? const Center(child: Text("No gifts available."))
          : ListView.builder(
        itemCount: _gifts.length,
        itemBuilder: (context, index) {
          final gift = _gifts[index];
          return ListTile(
            title: Text(gift.name),
            subtitle: Text(gift.description),
          );
        },
      ),
    );
  }
}
