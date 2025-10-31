class ChatGetMessageResponseDto {
  final List<ChatGetMessageItemDto> message;

  ChatGetMessageResponseDto({required this.message});

  factory ChatGetMessageResponseDto.fromJson(Map<String, dynamic> json) {
    final list = (json['MESSAGE'] as List?) ?? const [];
    return ChatGetMessageResponseDto(
      message: list
          .map((e) => ChatGetMessageItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChatGetMessageItemDto {
  final int iddv;
  final String sm1;
  final String sm2;
  final int idGroup;
  final int idMessage;
  final int idSender;
  final String? content;
  final int? replyToID;
  final DateTime? dateSent;
  final int statusMess;
  final int typeMessage;
  final String? fileSend;
  final String? fullNameUser;
  final String? avatarImg;
  final String? replyToContent;
  final String? fileName;
  final String? fileNameCode;

  ChatGetMessageItemDto({
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
    this.fileSend,
    this.fullNameUser,
    this.avatarImg,
    this.replyToContent,
    this.fileName,
    this.fileNameCode,
  });

  factory ChatGetMessageItemDto.fromJson(Map<String, dynamic> json) {
    int _i(v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    String? _s(v) => v?.toString();
    DateTime? _d(v) {
      final s = _s(v);
      if (s == null || s.trim().isEmpty) return null;
      return DateTime.tryParse(s);
    }

    return ChatGetMessageItemDto(
      iddv: _i(json['IDDV']),
      sm1: _s(json['SM1']) ?? '',
      sm2: _s(json['SM2']) ?? '',
      idGroup: _i(json['ID_GROUP']),
      idMessage: _i(json['ID_MESSAGE']),
      idSender: _i(json['ID_SENDER']),
      content: _s(json['CONTENT']),
      replyToID: json['REPLYTOID'] != null ? _i(json['REPLYTOID']) : null,
      dateSent: _d(json['DATE_SENT']),           // ✅ đúng key
      statusMess: _i(json['STATUS_MES']),
      typeMessage: _i(json['TYPE_MESSAGE']),
      fileSend: _s(json['FILE_SEND']),
      fullNameUser: _s(json['FULLNAME_USER']),
      avatarImg: _s(json['AVATAR_IMG']),
      replyToContent: _s(json['REPLY_TO_CONTENT']),
      fileName: _s(json['FILE_NAME']),
      fileNameCode: _s(json['FILENAME_CODE']),
    );
  }
}
