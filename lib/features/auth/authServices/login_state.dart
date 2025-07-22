class LoginState {
  final bool isLoading;
  final String? error;
  final bool success;

  const LoginState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  factory LoginState.idle() => const LoginState(
    isLoading: false,
    success: false,
  );

  factory LoginState.loading() => const LoginState(
    isLoading: true,
    success: false,
  );

  factory LoginState.success() => const LoginState(
    isLoading: false,
    success: true,
  );

  factory LoginState.error(String message) => LoginState(
    isLoading: false,
    success: false,
    error: message,
  );

}
