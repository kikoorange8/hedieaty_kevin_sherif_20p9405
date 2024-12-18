class Event {
  final String id;
  final String name;
  final String date;
  final String location;
  final String description;
  final String userId;
  final int published; // 0 for not published, 1 for published

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.userId,
    this.published = 0,
  });

  // Convert Event to a Map for database operations
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

  // Create Event from a Map
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      name: map['name'],
      date: map['date'],
      location: map['location'],
      description: map['description'],
      userId: map['userId'],
      published: map['published'] ?? 0,
    );
  }

  // copyWith method to create a modified copy of Event
  Event copyWith({
    String? id,
    String? name,
    String? date,
    String? location,
    String? description,
    String? userId,
    int? published,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      location: location ?? this.location,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      published: published ?? this.published,
    );
  }
}
