class User {
  final String id; // Changed to String
  final String name;
  final String email;
  final String? preferences;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.preferences,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'preferences': preferences,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      preferences: map['preferences'],
    );
  }
}
