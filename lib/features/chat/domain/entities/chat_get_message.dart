import 'dart:convert';

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

  const ChatGetMessage(
      this.iddv,
      this.sm1,
      this.sm2,
      this.idGroup, {
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

  bool get hasReply =>
      replyToID != null &&
          replyToID!.isNotEmpty &&
          replyToContent != null &&
          replyToContent!.isNotEmpty;

  /// ✅ Parse từ JSON (SignalR / API)
  factory ChatGetMessage.fromJson(Map<String, dynamic> json) {
    return ChatGetMessage(
      json['IDDV'] ?? json['iddv'] ?? 0,
      json['SM1'] ?? json['sm1'] ?? '',
      json['SM2'] ?? json['sm2'] ?? '',
      json['ID_GROUP'] ?? json['idGroup'] ?? 0,
      idMessage: (json['ID_MESSAGE'] ?? json['idMessage'] ?? '').toString(),
      idSender: json['ID_SENDER'] ?? json['idSender'] ?? 0,
      content: json['CONTENT'] ?? json['content'] ?? '',
      replyToID: json['REPLY_TO_ID'] ?? json['replyToID'],
      dateSent: _parseDate(json['DATE_SENT'] ?? json['dateSent']),
      statusMess: json['STATUS_MESS'] ?? json['statusMess'] ?? 0,
      typeMessage: json['TYPE_MESSAGE'] ?? json['typeMessage'] ?? 0,
      fileSend: json['FILE_SEND'] ?? json['fileSend'],
      fullNameUser: json['FULLNAME_USER'] ?? json['fullNameUser'] ?? '',
      avatarImg: json['IMG_AVA'] ?? json['avatarImg'],
      replyToContent: json['REPLY_TO_CONTENT'] ?? json['replyToContent'],
      fileName: json['FILE_NAME'] ?? json['fileName'],
      fileNameCode: json['FILE_NAME_CODE'] ?? json['fileNameCode'],
    );
  }

  /// ✅ Parse từ String JSON
  factory ChatGetMessage.fromJsonString(String raw) {
    final Map<String, dynamic> json = jsonDecode(raw);
    return ChatGetMessage.fromJson(json);
  }

  /// ✅ Chuyển ngược lại thành Map (nếu cần lưu local)
  Map<String, dynamic> toJson() => {
    'IDDV': iddv,
    'SM1': sm1,
    'SM2': sm2,
    'ID_GROUP': idGroup,
    'ID_MESSAGE': idMessage,
    'ID_SENDER': idSender,
    'CONTENT': content,
    'REPLY_TO_ID': replyToID,
    'DATE_SENT': dateSent?.toIso8601String(),
    'STATUS_MESS': statusMess,
    'TYPE_MESSAGE': typeMessage,
    'FILE_SEND': fileSend,
    'FULLNAME_USER': fullNameUser,
    'IMG_AVA': avatarImg,
    'REPLY_TO_CONTENT': replyToContent,
    'FILE_NAME': fileName,
    'FILE_NAME_CODE': fileNameCode,
  };

  /// 🕐 Helper parse DateTime an toàn
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}
