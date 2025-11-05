import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:chat_mobile_app/core/constants/app_contain.dart';
import 'package:chat_mobile_app/core/constants/flutter_secure_storage.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/login_result.dart';
import '../dtos/login_response_dto.dart';
import '../mappers/login_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl(this._dio);

  @override
  Future<LoginResult> login(String user, String password) async {
    try {
      final response = await _dio.post(
        EndPoint.loginUrl,
        data: {'user': user, 'password': password},
      );

      dynamic raw = response.data;
      if (raw is String) raw = jsonDecode(raw);

      print("📦 [AuthRepositoryImpl] raw API response: $raw");

      if (raw is! Map || raw['TYPE'] != 'SUCCESS') {
        final msg = (raw is Map ? raw['MESSAGE'] : null)?.toString() ?? 'Đăng nhập thất bại';
        throw Exception(msg);
      }

      // ✅ Lấy dữ liệu gốc từ JSON
      final message = raw['MESSAGE'];
      final userList = message?['USER_INFO'] as List?;
      final userData = (userList != null && userList.isNotEmpty)
          ? userList.first as Map<String, dynamic>
          : null;

      final fullName = userData?['FULLNAME_USER']?.toString() ?? '';
      final avatar = userData?['IMG_AVA']?.toString() ?? '';

      // ✅ Parse DTO nếu cần
      final dto = LoginResponseDto.fromJson(raw as Map<String, dynamic>);
      final entity = dto.toEntity();

      // ✅ Lưu session (ưu tiên lấy từ JSON gốc cho chắc)
      await LocalStorageService.saveLoginData(
        token: entity.token,
        iddv: int.tryParse(userData?['IDDV'].toString() ?? '0') ?? 0,
        sm1: userData?['SM1']?.toString() ?? '',
        sm2: userData?['SM2']?.toString() ?? '',
        quyen: userData?['QUYEN']?.toString() ?? '',
        user: int.tryParse(userData?['ID_USER'].toString() ?? '0') ?? 0,
        fullNameUser: fullName,
        avatarUrl: avatar,
      );

      print("💾 Saved LoginData → FULLNAME_USER=$fullName | IMG_AVA=$avatar");

      return entity;
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? 'Lỗi mạng hoặc server không phản hồi';
      throw Exception(msg);
    } catch (e) {
      throw Exception(e.toString());
    }
  }


  @override
  Future<void> logout() async {
    await LocalStorageService.clear();
  }
}
