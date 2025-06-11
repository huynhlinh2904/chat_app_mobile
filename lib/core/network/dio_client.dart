import 'package:dio/dio.dart';
import 'dio_response.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  final Dio _dio = Dio();

  DioClient._internal() {
    _dio.options.baseUrl = 'http://10.0.2.2:5500';
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  // === GET ===
  Future<ApiResponse> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      print("GET thành công:");
      print("Status: ${response.statusCode}");
      print("Data: ${response.data}");

      return ApiResponse.success(response.data);
    } catch (e) {
      final errorMessage = _handleError(e);
      return ApiResponse.failure(errorMessage);
    }
  }

  // === POST ===
  Future<ApiResponse> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.post(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options);
      return ApiResponse.success(response.data);
    } catch (e) {
      // Các lỗi không phải Dio
      final errorMessage = _handleError(e);
      return ApiResponse.failure(errorMessage);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      print("DioException:");
      print("Type: ${error.type}");
      print("Status: ${error.response?.statusCode}");
      print("URI: ${error.requestOptions.uri}");
      print("Message: ${error.message}");
      print("Response: ${error.response?.data}");

      return error.response?.data?.toString() ?? error.message ?? 'Lỗi không xác định từ server';
    }

    print("Unexpected error: $error");
    return 'Lỗi không xác định: $error';
  }
}
