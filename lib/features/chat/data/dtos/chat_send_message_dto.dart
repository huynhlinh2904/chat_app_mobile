class ChatSendMessageResponseDto {
  final String type;
  final List<ChatSendMessageItemDto> messages;

  ChatSendMessageResponseDto({
    required this.type,
    required this.messages,
  });

  factory ChatSendMessageResponseDto.fromJson(Map<String, dynamic> json) {
    return ChatSendMessageResponseDto(
      type: json['TYPE'] ?? '',
      messages: (json['MESSAGE'] as List<dynamic>)
          .map((e) => ChatSendMessageItemDto.fromJson(e))
          .toList(),
    );
  }
}
class ChatSendMessageItemDto {
  final int idGroup;
  final String idMessage;
  final int idSender;
  final String fullNameUser;
  final String content;
  final int replyToID;
  final String replyToContent;
  final String dateSent;
  final int typeMessage;
  final int type;
  final int statusMess;
  final String fileName;
  final String fileNameCode;

  ChatSendMessageItemDto({
    required this.idGroup,
    required this.idMessage,
    required this.idSender,
    required this.fullNameUser,
    required this.content,
    required this.replyToID,
    required this.replyToContent,
    required this.dateSent,
    required this.typeMessage,
    required this.type,
    required this.statusMess,
    required this.fileName,
    required this.fileNameCode,
  });

  factory ChatSendMessageItemDto.fromJson(Map<String, dynamic> json) {
    return ChatSendMessageItemDto(
      idGroup: json['ID_GROUP'] ?? 0,
      idMessage: json['ID_MESSAGE'] ?? '',
      idSender: json['ID_SENDER'] ?? 0,
      fullNameUser: json['FULLNAME_USER'] ?? '',
      content: json['CONTENT'] ?? '',
      replyToID: json['REPLY_TO_ID'] ?? 0,
      replyToContent: json['REPLY_TO_CONTENT'] ?? '',
      dateSent: json['DATE_SENT'] ?? '',
      typeMessage: json['TYPE_MESSAGE'] ?? 0,
      type: json['TYPE'] ?? 0,
      statusMess: json['STATUS_MESS'] ?? 0,
      fileName: json['FILE_NAME'] ?? '',
      fileNameCode: json['FILE_NAME_CODE'] ?? '',
    );
  }
}

