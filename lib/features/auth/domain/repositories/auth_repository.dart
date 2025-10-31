import '../entities/login_result.dart';

abstract class AuthRepository {
  Future<LoginResult> login(String username, String password);
  Future<void> logout();
}
