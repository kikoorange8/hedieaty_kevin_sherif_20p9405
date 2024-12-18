class Gift {
  final int? id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String status;
  final String? eventId; // Change to String?
  final String userId;
  final String? image;

  Gift({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    this.eventId, // Optional event ID
    required this.userId,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'eventId': eventId, // String
      'userId': userId,
      'image': image,
    };
  }

  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      price: map['price'] as double,
      status: map['status'] as String,
      eventId: map['eventId'] as String?, // Updated
      userId: map['userId'] as String,
      image: map['image'] as String?,
    );
  }
}
