class Friend {
  final int userId; // The ID of the current user
  final int friendId; // The ID of the friend
  final String friendName; // The friend's name
  final String friendProfilePicture; // The friend's profile picture URL or file path
  final bool hasUpcomingEvents; // Indicates if the friend has upcoming events

  Friend({
    required this.userId,
    required this.friendId,
    required this.friendName,
    required this.friendProfilePicture,
    required this.hasUpcomingEvents,
  });

  // Convert Friend to a Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'friendId': friendId,
      'friendName': friendName,
      'friendProfilePicture': friendProfilePicture,
      'hasUpcomingEvents': hasUpcomingEvents ? 1 : 0,
    };
  }

  // Create a Friend from a Map
  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      userId: map['userId'],
      friendId: map['friendId'],
      friendName: map['friendName'],
      friendProfilePicture: map['friendProfilePicture'],
      hasUpcomingEvents: map['hasUpcomingEvents'] == 1,
    );
  }
}
