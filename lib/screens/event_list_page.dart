import 'package:flutter/material.dart';

class EventListPage extends StatelessWidget {
  const EventListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event List'),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('Event 1'),
            subtitle: Text('Details about Event 1'),
          ),
          ListTile(
            title: Text('Event 2'),
            subtitle: Text('Details about Event 2'),
          ),
        ],
      ),
    );
  }
}
