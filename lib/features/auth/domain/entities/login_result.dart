import 'user.dart';

class LoginResult {
  final String type;
  final String token;
  final List<User> users;

  const LoginResult({required this.type, required this.token, required this.users});
}
