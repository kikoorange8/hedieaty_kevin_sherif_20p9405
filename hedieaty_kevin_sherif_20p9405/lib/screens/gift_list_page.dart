import 'package:flutter/material.dart';

class GiftListPage extends StatelessWidget {
  const GiftListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift List'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Gift 1'),
            subtitle: Text('Description of Gift 1'),
          ),
          ListTile(
            title: Text('Gift 2'),
            subtitle: Text('Description of Gift 2'),
          ),
          ListTile(
            title: Text('Gift 3'),
            subtitle: Text('Description of Gift 3'),
          ),
        ],
      ),
    );
  }
}
