class Gift {
  final int id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String status;
  final int? eventId; // Allow eventId to be nullable and an int
  final String userId;
  final String? image;

  Gift({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    this.eventId,
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
      'eventId': eventId,
      'userId': userId,
      'image': image,
    };
  }

  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      price: map['price'],
      status: map['status'],
      eventId: map['eventId'], // Allow direct assignment
      userId: map['userId'],
      image: map['image'],
    );
  }
}
