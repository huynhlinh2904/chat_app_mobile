class UserInfo {
  final int idUser;
  final String nameUser;
  final String roleUser;
  final String fullNameUser;
  final String? avatar;
  final String? QUYEN;

  UserInfo({
    required this.idUser,
    required this.nameUser,
    required this.roleUser,
    required this.fullNameUser,
    this.avatar,
    this.QUYEN,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      idUser: json['ID_USER'],
      nameUser: json['NAME_USER'] ?? '',
      roleUser: json['ROLE_USER'].toString(),
      fullNameUser: json['FULLNAME_USER'] ?? '',
      avatar: json['IMG_AVA'],
      QUYEN: json['QUYEN'].toString(),
    );
  }
}
