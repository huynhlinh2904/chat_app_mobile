import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';
import 'login_notifier.dart';
import 'login_state.dart';

final loginNotifierProvider =
StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  final authService = ref.read(authServiceProvider);
  return LoginNotifier(authService);
});
