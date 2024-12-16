class Friend {
  final String userId; // String for Firebase UID
  final String friendId; // String for the friend's UID
  final String friendName; // Friend's display name
  final String? friendProfilePicture; // Optional profile picture
  final bool hasUpcomingEvents; // Status indicator

  Friend({
    required this.userId,
    required this.friendId,
    required this.friendName,
    this.friendProfilePicture,
    required this.hasUpcomingEvents,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'friendId': friendId,
      'friendName': friendName,
      'friendProfilePicture': friendProfilePicture ?? '',
      'hasUpcomingEvents': hasUpcomingEvents ? 1 : 0,
    };
  }

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      userId: map['userId'],
      friendId: map['friendId'],
      friendName: map['friendName'],
      friendProfilePicture: map['friendProfilePicture'] ?? '',
      hasUpcomingEvents: map['hasUpcomingEvents'] == 1,
    );
  }
}
