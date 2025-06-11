class ChatUser {
  final int userId;
  final String fullName;
  final String? avatar;
  final bool isAdmin;

  ChatUser({
    required this.userId,
    required this.fullName,
    this.avatar,
    required this.isAdmin,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      userId: json['UserId'],
      fullName: json['FullName'],
      avatar: json['Avatar'],
      isAdmin: json['IsAdmin'],
    );
  }
}

class ChatMembersResponse {
  final List<ChatUser> members;
  final int totalMembers;

  ChatMembersResponse({
    required this.members,
    required this.totalMembers,
  });

  factory ChatMembersResponse.fromJson(Map<String, dynamic> json) {
    final membersJson = json['Members'] as List<dynamic>;
    final members = membersJson.map((e) => ChatUser.fromJson(e)).toList();

    return ChatMembersResponse(
      members: members,
      totalMembers: json['TotalMembers'],
    );
  }
}
