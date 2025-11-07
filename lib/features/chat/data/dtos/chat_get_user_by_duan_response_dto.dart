import 'dart:convert';
import '../../domain/entities/chat_get_user_duan.dart';

class ChatGetUserByDuanResponseDto {
  final String type;
  final List<ChatGroupProjectDto> projects;

  ChatGetUserByDuanResponseDto({
    required this.type,
    required this.projects,
  });

  factory ChatGetUserByDuanResponseDto.fromJson(Map<String, dynamic> data) {
    final type = (data['TYPE'] ?? '').toString();

    // 🔹 MESSAGE là 1 list, chứa 1 phần tử có key "JsonResult"
    final messageList = (data['MESSAGE'] as List?) ?? [];
    if (messageList.isEmpty) {
      return ChatGetUserByDuanResponseDto(type: type, projects: []);
    }

    // 🔹 Lấy phần tử đầu tiên và đọc trường JsonResult (chuỗi JSON)
    final first = messageList.first as Map<String, dynamic>;
    final jsonResultString = first['JsonResult']?.toString() ?? '[]';

    // 🔹 Parse chuỗi JSONResult thành List<Map<String, dynamic>>
    final List<dynamic> parsed = json.decode(jsonResultString);

    // 🔹 Chuyển từng phần tử thành ChatGroupProjectDto
    final projects = parsed
        .map((e) => ChatGroupProjectDto.fromJson(e as Map<String, dynamic>))
        .toList();

    return ChatGetUserByDuanResponseDto(type: type, projects: projects);
  }

  /// ✅ Chuyển toàn bộ DTO → danh sách entity (nếu bạn có entity trong domain)
  List<ChatGetUserDuan> toEntities() =>
      projects.map((p) => p.toEntity()).toList();
}


/// ✅ Mỗi Dự án / Nhóm
class ChatGroupProjectDto {
  final int idDuAn;
  final String maDuAn;
  final String tenDuAn;
  final List<ChatGroupUserDto> users;

  ChatGroupProjectDto({
    required this.idDuAn,
    required this.maDuAn,
    required this.tenDuAn,
    required this.users,
  });

  factory ChatGroupProjectDto.fromJson(Map<String, dynamic> json) {
    final users = (json['USERS'] as List?)
        ?.map((u) => ChatGroupUserDto.fromJson(u as Map<String, dynamic>))
        .toList() ??
        [];

    return ChatGroupProjectDto(
      idDuAn: (json['ID_DUAN'] as num?)?.toInt() ?? 0,
      maDuAn: (json['MA_DUAN'] ?? '').toString(),
      tenDuAn: (json['TEN_DUAN'] ?? '').toString(),
      users: users,
    );
  }

  /// 🔹 Convert 1 ProjectDto → Entity (nếu bạn có class ChatGroupProject)
  ChatGetUserDuan toEntity() {
    return ChatGetUserDuan(
      idDuAn: idDuAn,
      maDuAn: maDuAn,
      tenDuAn: tenDuAn,
      users: users.map((u) => u.toEntity()).toList(),
    );
  }
}

/// ✅ Người dùng trong dự án
class ChatGroupUserDto {
  final int idUser;
  final String fullNameUser;
  final String? chucVu;

  ChatGroupUserDto({
    required this.idUser,
    required this.fullNameUser,
    this.chucVu,
  });

  factory ChatGroupUserDto.fromJson(Map<String, dynamic> json) {
    return ChatGroupUserDto(
      idUser: (json['ID_USER'] as num?)?.toInt() ?? 0,
      fullNameUser: (json['FULLNAME_USER'] ?? '').toString(),
      chucVu: json['CHUCVU']?.toString(),
    );
  }

  /// 🔹 Convert UserDto → Entity (nếu bạn có ChatGroupUser entity)
  ChatGetGroupUserDuan toEntity() {
    return ChatGetGroupUserDuan(
      idUser: idUser,
      fullNameUser: fullNameUser,
      chucVu: chucVu,
    );
  }
}
