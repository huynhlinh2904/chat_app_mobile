class ChatGroup {
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
  final int? idDuan;
  final int? idUser1;
  final int? idUser2;
  final String? content;
  final int? typeMessage;
  final String? fileSend;
  final DateTime? dateSent;
  final DateTime? lastMessageDate;
  final int? idSender;
  final String? senderName;
  final int? idMessage;
  final DateTime? dateSort;
  final int rn;

  final String? lastMessage;
  final int unreadCount;   // ✅ non-null

  const ChatGroup({
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
    this.idDuan,
    this.idUser1,
    this.idUser2,
    this.content,
    this.typeMessage,
    this.fileSend,
    this.dateSent,
    this.lastMessageDate,
    this.idSender,
    this.senderName,
    this.idMessage,
    this.dateSort,
    required this.rn,
    this.lastMessage,
    this.unreadCount = 0, // ✅ default 0
  });
}

extension ChatGroupCopy on ChatGroup {
  ChatGroup copyWith({
    String? groupName,
    String? avatarImg,
    String? backgroundImg,
    int? isGroup,
    int? idUser,
    DateTime? createDate,
    String? creatorName,
    String? userName1,
    String? userName2,
    int? idDuan,
    int? idUser1,
    int? idUser2,
    String? content,
    int? typeMessage,
    String? fileSend,
    DateTime? dateSent,
    DateTime? lastMessageDate,
    int? idSender,
    String? senderName,
    int? idMessage,
    DateTime? dateSort,
    int? rn,
    String? lastMessage,
    int? unreadCount,
  }) {
    return ChatGroup(
      idGroup: idGroup,
      groupName: groupName ?? this.groupName,
      avatarImg: avatarImg ?? this.avatarImg,
      backgroundImg: backgroundImg ?? this.backgroundImg,
      isGroup: isGroup ?? this.isGroup,
      idUser: idUser ?? this.idUser,
      createDate: createDate ?? this.createDate,
      creatorName: creatorName ?? this.creatorName,
      userName1: userName1 ?? this.userName1,
      userName2: userName2 ?? this.userName2,
      idDuan: idDuan ?? this.idDuan,
      idUser1: idUser1 ?? this.idUser1,
      idUser2: idUser2 ?? this.idUser2,
      content: content ?? this.content,
      typeMessage: typeMessage ?? this.typeMessage,
      fileSend: fileSend ?? this.fileSend,
      dateSent: dateSent ?? this.dateSent,
      lastMessageDate: lastMessageDate ?? this.lastMessageDate,
      idSender: idSender ?? this.idSender,
      senderName: senderName ?? this.senderName,
      idMessage: idMessage ?? this.idMessage,
      dateSort: dateSort ?? this.dateSort,
      rn: rn ?? this.rn,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

