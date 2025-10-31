import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../core/network/dio_client.dart';

import 'login_state.dart';

// Bindings
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.read(dioProvider);
  return AuthRepositoryImpl(dio);
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});

final loginNotifierProvider =
StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(
    ref.read(loginUseCaseProvider),
    ref.read(logoutUseCaseProvider),
  );
});

class LoginNotifier extends StateNotifier<LoginState> {
  final LoginUseCase _login;
  final LogoutUseCase _logout;

  LoginNotifier(this._login, this._logout) : super(LoginState.idle());

  Future<void> login(BuildContext context, String username, String password) async {
    state = LoginState.loading();
    try {
      await _login(username, password);
      state = LoginState.success();
      Navigator.pushReplacementNamed(context, '/main_navigation_menu')
          .then((_) => reset());
    } catch (e) {
      state = LoginState.error(e.toString());
      _showError(context, state.error ?? 'Đăng nhập thất bại');
    }
  }


  Future<void> logout(BuildContext context) async {
    await _logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  void reset() => state = LoginState.idle();

  void _showError(BuildContext c, String m) {
    showDialog(
      context: c,
      builder: (_) => AlertDialog(
        title: const Text('Lỗi đăng nhập'),
        content: Text(m),
        actions: [
          TextButton(onPressed: () { Navigator.of(c).pop(); reset(); }, child: const Text('OK')),
        ],
      ),
    );
  }
}
