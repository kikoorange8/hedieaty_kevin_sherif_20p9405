import 'package:flutter/material.dart';

class PledgedGiftPage extends StatelessWidget {
  const PledgedGiftPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pledged Gifts'),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Pledged Gift 1'),
            subtitle: Text('Details about Pledged Gift 1'),
          ),
          ListTile(
            title: Text('Pledged Gift 2'),
            subtitle: Text('Details about Pledged Gift 2'),
          ),
        ],
      ),
    );
  }
}
