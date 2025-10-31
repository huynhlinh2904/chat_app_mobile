class LoginState {
  final bool isLoading;
  final bool success;
  final String? error;

  const LoginState({required this.isLoading, required this.success, this.error});

  factory LoginState.idle() => const LoginState(isLoading: false, success: false);
  factory LoginState.loading() => const LoginState(isLoading: true, success: false);
  factory LoginState.success() => const LoginState(isLoading: false, success: true);
  factory LoginState.error(String message) =>
      LoginState(isLoading: false, success: false, error: message);

  LoginState copyWith({bool? isLoading, bool? success, String? error}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: error,
    );
  }
}
