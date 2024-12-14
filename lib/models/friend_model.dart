class Friend {
  final int userId;
  final int friendId;
  final String friendName;
  final String friendProfilePicture;
  final bool hasUpcomingEvents;

  Friend({
    required this.userId,
    required this.friendId,
    required this.friendName,
    required this.friendProfilePicture,
    required this.hasUpcomingEvents,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'friendId': friendId,
      'friendName': friendName,
      'friendProfilePicture': friendProfilePicture,
      'hasUpcomingEvents': hasUpcomingEvents ? 1 : 0,
    };
  }

  static Friend fromMap(Map<String, dynamic> map) {
    return Friend(
      userId: map['userId'],
      friendId: map['friendId'],
      friendName: map['friendName'],
      friendProfilePicture: map['friendProfilePicture'],
      hasUpcomingEvents: map['hasUpcomingEvents'] == 1,
    );
  }
}
