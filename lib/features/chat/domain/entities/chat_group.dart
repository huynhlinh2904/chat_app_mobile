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
    this.lastMessage,
    this.unreadCount = 0, // ✅ default 0
  });
}
