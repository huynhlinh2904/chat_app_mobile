class ChatGetMessageRedisResponseDto {
  final List<ChatGetMessageRedisItemDto> message;

  ChatGetMessageRedisResponseDto({required this.message});

  factory ChatGetMessageRedisResponseDto.fromJson(Map<String, dynamic> json) {
    final list = (json['MESSAGE'] as List?) ?? const [];
    return ChatGetMessageRedisResponseDto(
      message: list
          .map((e) => ChatGetMessageRedisItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChatGetMessageRedisItemDto {
  final int iddv;
  final String sm1;
  final String sm2;
  final int idGroup;
  final String idMessage;
  final int idSender;
  final String? fullNameUser;
  final String? content;
  final String? replyToID;
  final int typeMessage;
  final int type;
  final String? replyToContent;
  final DateTime? dateSent;
  final String? fileName;
  final String? fileNameCode;
  final int statusMess;



  ChatGetMessageRedisItemDto({
    required this.iddv,
    required this.sm1,
    required this.sm2,
    required this.idGroup,
    required this.idMessage,
    required this.idSender,
    this.content,
    this.replyToID,
    this.dateSent,
    required this.statusMess,
    required this.typeMessage,
    required this.type,
    this.fullNameUser,
    this.replyToContent,
    this.fileName,
    this.fileNameCode,
  });

  factory ChatGetMessageRedisItemDto.fromJson(Map<String, dynamic> json) {
    int _i(v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    String? _s(v) => v?.toString();
    DateTime? _d(v) {
      final s = _s(v);
      if (s == null || s.trim().isEmpty) return null;
      return DateTime.tryParse(s);
    }

    return ChatGetMessageRedisItemDto(
      iddv: _i(json['IDDV']),
      sm1: _s(json['SM1']) ?? '',
      sm2: _s(json['SM2']) ?? '',
      idGroup: _i(json['ID_GROUP']),
      idMessage: json['ID_MESSAGE'].toString(),
      idSender: _i(json['ID_SENDER']),
      content: _s(json['CONTENT']),
      replyToID: json['REPLYTOID'].toString(),
      dateSent: _d(json['DATE_SENT']),           // ✅ đúng key
      statusMess: _i(json['STATUS_MES']),
      typeMessage: _i(json['TYPE_MESSAGE']),
      type: _i(json['TYPE']),
      fullNameUser: _s(json['FULLNAME_USER']),
      replyToContent: _s(json['REPLY_TO_CONTENT']),
      fileName: _s(json['FILE_NAME']),
      fileNameCode: _s(json['FILENAME_CODE']),
    );
  }
}
