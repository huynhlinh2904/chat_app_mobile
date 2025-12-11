class ChatCreateGroupResponseDTO {
  final String type;
  final List<ChatCreateGroupItemDTO> message;

  ChatCreateGroupResponseDTO({
    required this.type,
    required this.message,
  });

  factory ChatCreateGroupResponseDTO.fromJson(Map<String, dynamic> json) {
    final list = (json["MESSAGE"] as List? ?? []);

    return ChatCreateGroupResponseDTO(
      type: json["TYPE"]?.toString() ?? "",
      message: list.map((e) => ChatCreateGroupItemDTO.fromJson(e)).toList(),
    );
  }
}

class ChatCreateGroupItemDTO {
  final int iddv;
  final String sm1;
  final String sm2;
  final int idGroup;
  final String groupName;

  ChatCreateGroupItemDTO({
    required this.iddv,
    required this.sm1,
    required this.sm2,
    required this.idGroup,
    required this.groupName,
  });

  factory ChatCreateGroupItemDTO.fromJson(Map<String, dynamic> json) {
    return ChatCreateGroupItemDTO(
      iddv: json["IDDV"] ?? 0,
      sm1: json["SM1"] ?? "",
      sm2: json["SM2"] ?? "",
      idGroup: json["ID_GROUP"] ?? 0,
      groupName: json["GROUP_NAME"] ?? "",
    );
  }
}
