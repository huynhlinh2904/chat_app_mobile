import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';
import 'login_state.dart';

final loginNotifierProvider =
StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  final authService = ref.read(authServiceProvider);
  return LoginNotifier(authService);
});

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthService _authService;

  LoginNotifier(this._authService) : super(LoginState.idle());

  Future<void> login(BuildContext context, String username, String password) async {
    state = state.copyWith(isLoading: true);
    state = LoginState.loading();
    final result = await _authService.login(username, password);
    if (result != null) {
      Navigator.pushReplacementNamed(context, '/main_navigation_menu')
          .then((_) => reset());
      state = LoginState.success();

    } else {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
        title: const Text('Lỗi đăng nhập'),
        content: const Text('Tài khoản hoặc mật khẩu không đúng'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              reset();
            },
            child: const Text('OK'),
          ),
        ],
      ),
      );
    };
  }

  void reset() {
    state = LoginState.idle();
  }
}