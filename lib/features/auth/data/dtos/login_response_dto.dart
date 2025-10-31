import 'package:chat_mobile_app/features/auth/data/dtos/user_info_dto.dart';

class LoginResponseDto {
  final String type;
  final List<UserInfoDto> userInfoList;
  final String token;

  LoginResponseDto({
    required this.type,
    required this.userInfoList,
    required this.token,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    final message = json['MESSAGE'] as Map<String, dynamic>;

    final userInfoRaw = message['USER_INFO'] as List;
    final tokenRaw = message['TOKEN']?['Token'] ?? '';

    return LoginResponseDto(
      type: json['TYPE'] ?? '',
      userInfoList: userInfoRaw.map((e) => UserInfoDto.fromJson(e)).toList(),
      token: tokenRaw,
    );
  }
}