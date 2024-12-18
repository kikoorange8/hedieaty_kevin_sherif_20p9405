class Friend {
  final String userId; // Firebase UID of the user
  final String friendId; // Firebase UID of the friend

  Friend({
    required this.userId,
    required this.friendId,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'friendId': friendId,
    };
  }

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      userId: map['userId'],
      friendId: map['friendId'],
    );
  }
}
