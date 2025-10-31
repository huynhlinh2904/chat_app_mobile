import '../dtos/login_response_dto.dart';
import '../dtos/user_info_dto.dart';
import '../../domain/entities/login_result.dart';
import '../../domain/entities/user.dart';

extension LoginResponseDtoMapper on LoginResponseDto {
  LoginResult toEntity() => LoginResult(
    type: type,
    token: token,
    users: userInfoList.map((u) => u.toEntity()).toList(),
  );
}

extension UserInfoDtoMapper on UserInfoDto {
  User toEntity() => User(
    orgId: iddv,
    code1: sm1,
    code2: sm2,
    role: quyen,
    userId: idUser,
  );
}
