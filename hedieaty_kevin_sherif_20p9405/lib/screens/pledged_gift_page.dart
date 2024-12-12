import 'package:flutter/material.dart';

class PledgedGiftPage extends StatelessWidget {
  const PledgedGiftPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pledged Gifts'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Pledged Gift 1'),
            subtitle: Text('Details about Pledged Gift 1'),
          ),
          ListTile(
            title: Text('Pledged Gift 2'),
            subtitle: Text('Details about Pledged Gift 2'),
          ),
          ListTile(
            title: Text('Pledged Gift 3'),
            subtitle: Text('Details about Pledged Gift 3'),
          ),
        ],
      ),
    );
  }
}
