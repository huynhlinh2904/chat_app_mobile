import 'dart:convert';
import 'package:chat_mobile_app/core/constants/app_contain.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/flutter_secure_storage.dart';
import '../../../core/network/dio_client.dart';
import '../../models/authModel/login_response.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.read(dioProvider);
  return AuthService(dio);
});

class AuthService {
  final Dio dio;
  AuthService(this.dio);

  Future<LoginResponse?> login(String user, String password) async {
    try {
      final response = await dio.post(EndPoint.loginUrl, data: {
        'user': user,
        'password': password,
      });

      dynamic raw = response.data;
      if (raw is String) raw = jsonDecode(raw);

      final data = LoginResponse.fromJson(raw);
      final userInfo = data.userInfoList.first;

      await LocalStorageService.saveLoginData(
        token: data.token,
        iddv: userInfo.iddv?.toString() ?? '',
        sm1: userInfo.sm1 ?? '',
        sm2: userInfo.sm2 ?? '',
        quyen: userInfo.quyen ?? '',
      );

      return data;
    } on DioException catch (e) {
      print('Login failed: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Unexpected login error: $e');
      return null;
    }
  }
}
