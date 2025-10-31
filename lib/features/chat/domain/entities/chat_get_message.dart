class ChatGetMessage {
  final int iddv;
  final String sm1;
  final String sm2;
  final int idGroup;
  final String idMessage;
  final int idSender;
  final String? content;
  final String? replyToID;
  final DateTime? dateSent;
  final int statusMess;
  final int typeMessage;
  final String? fileSend;
  final String? fullNameUser;
  final String? avatarImg;
  final String? replyToContent;
  final String? fileName;
  final String? fileNameCode;

  const ChatGetMessage(this.iddv, this.sm1, this.sm2, this.idGroup, {
    required this.idMessage,
    required this.idSender,
    required this.content,
    required this.replyToID,
    required this.dateSent,
    required this.statusMess,
    required this.typeMessage,
    required this.fileSend,
    required this.fullNameUser,
    required this.avatarImg,
    required this.replyToContent,
    required this.fileName,
    required this.fileNameCode,
  });
}