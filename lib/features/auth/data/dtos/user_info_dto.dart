class UserInfoDto {
  final int? iddv;
  final String? sm1;
  final String? sm2;
  final String? quyen;
  final int? idUser;

  UserInfoDto({
    this.iddv,
    this.sm1,
    this.sm2,
    this.quyen,
    this.idUser,
  });

  factory UserInfoDto.fromJson(Map<String, dynamic> json) {
    return UserInfoDto(
      iddv: json['IDDV'],
      sm1: json['SM1'],
      sm2: json['SM2'],
      quyen: json['QUYEN'],
      idUser: json['ID_USER'],
    );
  }
}