class UserInfoDto {
  final int? iddv;
  final String? sm1;
  final String? sm2;
  final String? quyen;
  final String? fullNameUser;
  final String? avatarUrl;
  final String? tenPb;
  final String? tendv;
  final int? idpb;
  final int? idUser;

  UserInfoDto({
    this.iddv,
    this.sm1,
    this.sm2,
    this.quyen,
    this.fullNameUser,
    this.avatarUrl,
    this.tenPb,
    this.tendv,
    this.idpb,
    this.idUser,
  });

  factory UserInfoDto.fromJson(Map<String, dynamic> json) {
    return UserInfoDto(
      iddv: json['IDDV'],
      sm1: json['SM1'],
      sm2: json['SM2'],
      quyen: json['QUYEN'],
      fullNameUser: json['FULLNAME_USER'],
      avatarUrl: json['IMG_AVA'],
      tenPb: json['TEN_PB'],
      tendv: json['TENDONVI'],
      idpb: json['ID_PB'],
      idUser: json['ID_USER'],
    );
  }
}