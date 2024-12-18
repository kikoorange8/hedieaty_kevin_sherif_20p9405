class Event {
  final String id; // Ensure this is a String
  final String name;
  final String date;
  final String location;
  final String description;
  final String userId;
  final int published;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.userId,
    required this.published,
  });

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'location': location,
      'description': description,
      'userId': userId,
      'published': published,
    };
  }

  // Convert from Map
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as String, // Ensure the id is parsed as a String
      name: map['name'],
      date: map['date'],
      location: map['location'],
      description: map['description'] ?? '',
      userId: map['userId'],
      published: map['published'] ?? 0,
    );
  }
}
