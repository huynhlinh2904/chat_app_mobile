class ChatUpdateOneToGroup {
  final String type;
  final List<ChatUpdateOneToGroupItemDto> messages;

  ChatUpdateOneToGroup({
    required this.type,
    required this.messages,
  });

  factory ChatUpdateOneToGroup.fromJson(Map<String, dynamic> json) {
    return ChatUpdateOneToGroup(
      type: json['TYPE'] ?? '',
      messages: (json['MESSAGE'] as List<dynamic>)
          .map((e) => ChatUpdateOneToGroupItemDto.fromJson(e))
          .toList(),
    );
  }
}
class ChatUpdateOneToGroupItemDto {
  final int iddv;
  final String sm1;
  final String sm2;
  final int idGroup;
  final int idUser1;
  final int idUser2;
  ChatUpdateOneToGroupItemDto({
    required this.iddv,
    required this.sm1,
    required this.sm2,
    required this.idGroup,
    required this.idUser1,
    required this.idUser2,
  });

  factory ChatUpdateOneToGroupItemDto.fromJson(Map<String, dynamic> json) {
    return ChatUpdateOneToGroupItemDto(
      iddv: json['IDDV'] ?? 0,
      sm1: json['SM1'] ?? '',
      sm2: json['SM2'] ?? '',
      idGroup: json['ID_GROUP'] ?? '',
      idUser1: json['ID_USER1'] ?? '',
      idUser2: json['ID_USER2'] ?? 0,
    );
  }
}

