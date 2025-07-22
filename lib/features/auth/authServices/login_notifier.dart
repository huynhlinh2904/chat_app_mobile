import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_response.dart';
import '../../../features/models/login_response.dart';
import 'login_state.dart';
import '../authServices/auth_service.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthService authService;
  LoginNotifier(this.authService) : super(LoginState.idle());

  Future<void> login(String username, String password) async {
    state = LoginState.loading();

    final result = await authService.login(username, password);

    if (result.isSuccess) {
      final user = result.data!.userInfoList.first;
      final token = result.data!.token;

      // Lưu token nếu cần
      // ref.read(authTokenProvider.notifier).state = token;

      state = LoginState.success();
    } else {
      state = LoginState.error(result.error ?? 'Đăng nhập thất bại');
    }
  }

  void reset() => state = LoginState.idle();
}
