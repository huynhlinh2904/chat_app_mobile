import 'package:chat_mobile_app/features/chat/data/clients/signalr_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/flutter_secure_storage.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../core/network/dio_client.dart';
import 'current_user_provider.dart';
import 'login_state.dart';

/// ================================
/// 🔗 PROVIDERS
/// ================================
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
    ref,
  );
});

/// ================================
/// 👤 LOGIN NOTIFIER
/// ================================
class LoginNotifier extends StateNotifier<LoginState> {
  final LoginUseCase _login;
  final LogoutUseCase _logout;
  final Ref _ref;

  LoginNotifier(this._login, this._logout, this._ref)
      : super(LoginState.idle());

  /// ================================
  /// 🔐 LOGIN FLOW
  /// ================================
  Future<void> login(
      BuildContext context,
      String username,
      String password,
      ) async {
    state = LoginState.loading();
    try {
      // 1️⃣ Gọi login API
      await _login(username, password);

      // 2️⃣ Lấy token đã lưu
      final token = await LocalStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("Token không hợp lệ hoặc trống");
      }

      // 3️⃣ Kết nối SignalR
      await SignalRService().initConnection(token);

      // 4️⃣ In toàn bộ thông tin đã lưu
      await LocalStorageService.debugPrintLoginData();

      // 🟢 5️⃣ Refresh lại thông tin người dùng (Profile)
      _ref.invalidate(currentUserProvider);

      // 6️⃣ Chuyển đến màn hình chính
      state = LoginState.success();
      Navigator.pushReplacementNamed(context, '/main_navigation_menu')
          .then((_) => reset());
    } catch (e, st) {
      debugPrint("❌ [LoginNotifier] Lỗi login: $e\n$st");
      state = LoginState.error(e.toString());
      _showError(context, state.error ?? 'Đăng nhập thất bại');
    }
  }

  /// ================================
  /// 🚪 LOGOUT
  /// ================================
  Future<void> logout(BuildContext context) async {
    await _logout();
    await LocalStorageService.clear();
    _ref.invalidate(currentUserProvider); // 🧹 clear provider user
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  /// ================================
  /// 🧾 RESET STATE
  /// ================================
  void reset() => state = LoginState.idle();

  /// ================================
  /// ⚠️ HIỂN THỊ LỖI
  /// ================================
  void _showError(BuildContext c, String m) {
    showDialog(
      context: c,
      builder: (_) => AlertDialog(
        title: const Text('Lỗi đăng nhập'),
        content: Text(m),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(c).pop();
              reset();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
