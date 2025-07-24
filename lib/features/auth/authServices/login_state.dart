class LoginState {
  final bool isLoading;
  final bool success;
  final String? error;

  LoginState({
    required this.isLoading,
    required this.success,
    this.error,
  });

  factory LoginState.idle() => LoginState(isLoading: false, success: false, error: null);
  factory LoginState.loading() => LoginState(isLoading: true, success: false, error: null);
  factory LoginState.success() => LoginState(isLoading: false, success: true, error: null);
  factory LoginState.error(String message) =>
      LoginState(isLoading: false, success: false, error: message);

  // 👇 Thêm hàm copyWith
  LoginState copyWith({
    bool? isLoading,
    bool? success,
    String? error,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: error,
    );
  }
}