import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 168, 144, 207),
              ),
              child: const Text('Create Your Own Event/List'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 2, // number of example friends
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage('assets/profile_placeholder.png'), // friend profile pic
                  ),
                  title: Text('Friend ${index + 1}'),
                  subtitle: Text(index % 2 == 0 ? 'Upcoming Events: ${index % 3 + 1}' : 'No Upcoming Events'),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
        },
        label: const Text('Add Friend'),
        icon: Icon(Icons.person_add),
        backgroundColor: const Color.fromARGB(255, 180, 160, 216),
      ),
    );
  }
}
