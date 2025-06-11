class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? error;

  ApiResponse._({required this.isSuccess, this.data, this.error});

  factory ApiResponse.success(T data) {
    return ApiResponse._(isSuccess: true, data: data);
  }

  factory ApiResponse.failure(String error) {
    return ApiResponse._(isSuccess: false, error: error);
  }
}