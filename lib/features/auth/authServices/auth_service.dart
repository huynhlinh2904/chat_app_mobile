import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/dio_response.dart';
import '../../models/login_response.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.read(dioProvider);
  return AuthService(dio);
});

class AuthService {
  final Dio dio;
  AuthService(this.dio);

  Future<ApiResponse<LoginResponse>> login(String user, String password) async {
    try {
      final response = await dio.post('/api/Authenticate/Login', data: {
        'user': user,
        'password': password.toString(),
      });

      final data = LoginResponse.fromJson(response.data);
      return ApiResponse.success(data);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'login fail';
      return ApiResponse.failure(msg);
    } catch (e) {
      return ApiResponse.failure('server error');
    }
  }
}