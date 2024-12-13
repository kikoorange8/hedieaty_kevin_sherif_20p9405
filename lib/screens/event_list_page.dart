import 'package:flutter/material.dart';

class EventListPage extends StatelessWidget {
  const EventListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event List'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Event 1'),
            subtitle: Text('Details about Event 1'),
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Event 2'),
            subtitle: Text('Details about Event 2'),
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Event 3'),
            subtitle: Text('Details about Event 3'),
          ),
        ],
      ),
    );
  }
}
