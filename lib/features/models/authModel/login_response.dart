class LoginResponse {
  final String type;
  final List<UserInfo> userInfoList;
  final String token;

  LoginResponse({
    required this.type,
    required this.userInfoList,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final message = json['MESSAGE'] as Map<String, dynamic>;

    final userInfoRaw = message['USER_INFO'] as List;
    final tokenRaw = message['TOKEN']?['Token'] ?? '';

    return LoginResponse(
      type: json['TYPE'] ?? '',
      userInfoList: userInfoRaw.map((e) => UserInfo.fromJson(e)).toList(),
      token: tokenRaw,
    );
  }
}

class UserInfo {
  final int? iddv;
  final String? sm1;
  final String? sm2;
  final String? quyen;

  UserInfo({
    this.iddv,
    this.sm1,
    this.sm2,
    this.quyen,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      iddv: json['IDDV'],
      sm1: json['SM1'],
      sm2: json['SM2'],
      quyen: json['QUYEN'],
    );
  }
}
