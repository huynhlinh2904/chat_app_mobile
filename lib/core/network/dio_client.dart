import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/login_notifier.dart';
import '../constants/app_contain.dart';
import '../constants/flutter_secure_storage.dart';

final Provider<Dio> dioProvider = Provider((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: EndPoint.apiService,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // BƯỚC 0: Bỏ qua interceptor nếu gọi login hoặc refresh
        if (options.path.contains("Authenticate/Login")) {
          return handler.next(options);
        }

        // BƯỚC 1: Kiểm tra token còn hạn không
        final loginNotifier = ref.read(loginNotifierProvider.notifier);
        final valid = await loginNotifier.ensureValidToken();

        if (!valid) {
          return handler.reject(
            DioException(
              requestOptions: options,
              error: "Token expired. Please login again.",
            ),
          );
        }

        // BƯỚC 2: Gắn token vào header
        final token = await LocalStorageService.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
    ),
  );

  return dio;
});
