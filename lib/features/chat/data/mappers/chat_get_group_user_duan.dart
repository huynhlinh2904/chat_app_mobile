import 'dart:convert';
import '../../domain/entities/chat_get_user_duan.dart';

class ChatGroupResponseDto {
  final String type;
  final List<ChatGroupProjectDto> projects;

  ChatGroupResponseDto({
    required this.type,
    required this.projects,
  });

  factory ChatGroupResponseDto.fromJson(Map<String, dynamic> json) {
    final type = (json['TYPE'] ?? '').toString();
    final messageList = (json['MESSAGE'] as List?) ?? [];
    if (messageList.isEmpty) {
      return ChatGroupResponseDto(type: type, projects: []);
    }

    final first = messageList.first as Map<String, dynamic>;
    final jsonResultString = first['JsonResult']?.toString() ?? '[]';
    final List<dynamic> parsed = jsonDecode(jsonResultString);
    final projects = parsed
        .map((e) => ChatGroupProjectDto.fromJson(e as Map<String, dynamic>))
        .toList();

    return ChatGroupResponseDto(type: type, projects: projects);
  }

  /// 🔹 Convert toàn bộ response sang danh sách Entity
  List<ChatGetUserDuan> toEntities() =>
      projects.map((p) => p.toEntity()).toList();
}

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

  /// 🔹 Convert 1 ProjectDto → Entity
  ChatGetUserDuan toEntity() {
    return ChatGetUserDuan(
      idDuAn: idDuAn,
      maDuAn: maDuAn,
      tenDuAn: tenDuAn,
      users: users.map((u) => u.toEntity()).toList(),
    );
  }
}

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

  /// 🔹 Convert UserDto → Entity
  ChatGetGroupUserDuan toEntity() {
    return ChatGetGroupUserDuan(
      idUser: idUser,
      fullNameUser: fullNameUser,
      chucVu: chucVu,
    );
  }
}
