import '../entities/login_result.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repo;
  const LoginUseCase(this._repo);

  Future<LoginResult> call(String username, String password) {
    return _repo.login(username, password);
  }
}
