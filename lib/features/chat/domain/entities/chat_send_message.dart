class ChatSendMessage {
  final int idGroup;
  final String idMessage;
  final int idSender;
  final String fullNameUser;
  final String content;
  final String dateSent;
  final int replyToID;
  final String replyToContent;
  final int typeMessage;

  const ChatSendMessage({
    required this.idGroup,
    required this.idMessage,
    required this.idSender,
    required this.fullNameUser,
    required this.content,
    required this.dateSent,
    required this.replyToID,
    required this.replyToContent,
    required this.typeMessage,
  });
}
