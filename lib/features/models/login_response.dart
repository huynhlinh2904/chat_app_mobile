import 'user_info.dart';

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
    final userList = (message['USER_INFO'] as List)
        .map((e) => UserInfo.fromJson(e as Map<String, dynamic>))
        .toList();

    final token = message['TOKEN']?['Token'] ?? '';

    return LoginResponse(
      type: json['TYPE'] ?? '',
      userInfoList: userList,
      token: token,
    );
  }
}
