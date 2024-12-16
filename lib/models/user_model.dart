class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String preferences;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.preferences = '',
  });

  // Convert UserModel to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'preferences': preferences,
    };
  }

  // Create UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      preferences: map['preferences'] ?? '',
    );
  }

  // copyWith method for immutability
  UserModel copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? preferences,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      preferences: preferences ?? this.preferences,
    );
  }
}
