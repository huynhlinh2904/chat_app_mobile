class ChatUserResponseDto {
  final String type;
  final List<ChatUserItemDto> message;

  ChatUserResponseDto({required this.type, required this.message});

  factory ChatUserResponseDto.fromJson(Map<String, dynamic> json) {
    return ChatUserResponseDto(
      type: json['TYPE'] ?? '',
      message: (json['MESSAGE'] as List<dynamic>)
          .map((e) => ChatUserItemDto.fromJson(e))
          .toList(),
    );
  }
}

class ChatUserItemDto {
  final int idUser;
  final String sdt;
  final String userName;
  final String email;
  final String address;
  final int gioiTinh;
  final String fullName;
  final int idPbPa;

  ChatUserItemDto({
    required this.idUser,
    required this.sdt,
    required this.userName,
    required this.email,
    required this.address,
    required this.gioiTinh,
    required this.fullName,
    required this.idPbPa,
  });

  factory ChatUserItemDto.fromJson(Map<String, dynamic> json) {
    return ChatUserItemDto(
      idUser: json['ID_USER'] ?? 0,
      sdt: json['SDT']?.toString() ?? '',
      userName: json['TEN'] ?? '',
      email: json['EMAIL'] ?? '',
      address: json['DIACHI'] ?? '',
      gioiTinh: json['GIOITINH'] ?? 0,
      fullName: json['FULLNAME_USER'] ?? '',
      idPbPa: json['ID_PB_PA'] ?? 0,
    );
  }
}
