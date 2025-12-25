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
  final String replyToID;
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
    String _s(dynamic v) => v?.toString() ?? '';
    return ChatSendMessageItemDto(
      idGroup: json['idGroup'] ?? json['ID_GROUP'] ?? 0,
      idMessage: _s(json['idMessage'] ?? json['ID_MESSAGE']),
      idSender: json['idSender'] ?? json['ID_SENDER'] ?? 0,
      fullNameUser: _s(json['fullnameUser'] ?? json['FULLNAME_USER']),
      content: _s(json['content'] ?? json['CONTENT']),
      replyToID: _s(json['replyToId'] ?? json['REPLYTOID']),
      replyToContent: _s(json['replyToContent'] ?? json['REPLY_TO_CONTENT']),
      dateSent: _s(json['dateSent'] ?? json['DATE_SENT']),
      typeMessage: json['typeMessage'] ?? json['TYPE_MESSAGE'] ?? 0,
      type: json['type'] ?? json['TYPE'] ?? 0,
      statusMess: json['statusMes'] ?? json['STATUS_MES'] ?? 0,
      fileName: _s(json['filename'] ?? json['FILE_NAME']),
      fileNameCode: _s(json['filenameCode'] ?? json['FILE_NAME_CODE']),
    );
  }
}

