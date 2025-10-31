class ChatGroupResponseDto {
  final String type;
  final List<ChatGroupItemDto> message;

  ChatGroupResponseDto({required this.type, required this.message});

  factory ChatGroupResponseDto.fromJson(Map<String, dynamic> json) {
    final list = (json['MESSAGE'] as List?) ?? const [];
    return ChatGroupResponseDto(
      type: (json['TYPE'] ?? '').toString(),
      message: list.map((e) => ChatGroupItemDto.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class ChatGroupItemDto {
  final int idGroup;
  final String groupName;
  final String? avatarImg;
  final String? backgroundImg;
  final int isGroup;
  final int? idUser;
  final DateTime? createDate;
  final String? creatorName;
  final String? userName1;
  final String? userName2;
  final int? idUser1;
  final int? idUser2;
  final String? content;
  final int? typeMessage;
  final String? fileSend;
  final DateTime? dateSent;
  final int? idSender;
  final String? senderName;
  final int? idMessage;
  final DateTime? dateSort;
  final int rn;

  final int? unreadCount;

  ChatGroupItemDto({
    required this.idGroup,
    required this.groupName,
    this.avatarImg,
    this.backgroundImg,
    required this.isGroup,
    this.idUser,
    this.createDate,
    this.creatorName,
    this.userName1,
    this.userName2,
    this.idUser1,
    this.idUser2,
    this.content,
    this.typeMessage,
    this.fileSend,
    this.dateSent,
    this.idSender,
    this.senderName,
    this.idMessage,
    this.dateSort,
    required this.rn,

    this.unreadCount
  });

  factory ChatGroupItemDto.fromJson(Map<String, dynamic> j) {
    DateTime? parse(String? s) => s == null ? null : DateTime.tryParse(s);
    return ChatGroupItemDto(
      idGroup: j['ID_GROUP'] as int,
      groupName: (j['GROUP_NAME'] ?? '').toString(),
      avatarImg: j['AVATAR_IMG'] as String?,
      backgroundImg: j['BACKGROUND_IMG'] as String?,
      isGroup: (j['IS_GROUP'] as num).toInt(),
      idUser: (j['ID_USER'] as num?)?.toInt(),
      createDate: parse(j['CREATE_DATE']?.toString()),
      creatorName: j['CREATOR_NAME'] as String?,
      userName1: j['USER_NAME_1'] as String?,
      userName2: j['USER_NAME_2'] as String?,
      idUser1: (j['ID_USER1'] as num?)?.toInt(),
      idUser2: (j['ID_USER2'] as num?)?.toInt(),
      content: j['CONTENT'] as String?,
      typeMessage: (j['TYPE_MESSAGE'] as num?)?.toInt(),
      fileSend: j['FILE_SEND'] as String?,
      dateSent: parse(j['DATE_SENT']?.toString()),
      idSender: (j['ID_SENDER'] as num?)?.toInt(),
      senderName: j['SENDER_NAME'] as String?,
      idMessage: (j['ID_MESSAGE'] as num?)?.toInt(),
      dateSort: parse(j['DATE_SORT']?.toString()),
      rn: (j['rn'] as num).toInt(),
    );
  }
}
