import 'package:flutter/material.dart';
import 'gift_details_page.dart';

class GiftListPage extends StatelessWidget {
  const GiftListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift List'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Gift 1'),
            subtitle: const Text('Description of Gift 1'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GiftDetailsPage(
                    giftName: 'Gift 1',
                    description: 'Description of Gift 1',
                    category: 'Books',
                    price: 20.0,
                    status: 'Available',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
