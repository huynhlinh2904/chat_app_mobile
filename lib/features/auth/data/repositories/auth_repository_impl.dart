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

      if (raw is! Map || raw['TYPE'] != 'SUCCESS') {
        final msg = (raw is Map ? raw['MESSAGE'] : null)?.toString() ?? 'Đăng nhập thất bại';
        throw Exception(msg);
      }

      final dto = LoginResponseDto.fromJson(raw as Map<String, dynamic>);
      final entity = dto.toEntity();

      // Lưu session
      final u = entity.users.isNotEmpty ? entity.users.first : null;
      await LocalStorageService.saveLoginData(
        token: entity.token,
        iddv: u?.orgId ?? 1,
        sm1: u?.code1 ?? '',
        sm2: u?.code2 ?? '',
        quyen: u?.role ?? '',
        user: u?.userId ?? 0,
        fullNameUser: u?.fullNameUser ?? '',
        avatarUrl: u?.avatarUrl ?? '',
      );

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
