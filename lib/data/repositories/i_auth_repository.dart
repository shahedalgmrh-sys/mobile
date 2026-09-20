import '../models/user_model.dart';

abstract class IAuthRepository {
  Future<User> sendOtp(String phone);

  Future<User> verifyOtp(String phone, String code);

  Future<User> register(Map<String, dynamic> data);

  Future<void> logout();

  Future<User> me();
}

class AuthResult {
  final User user;
  final String token;

  const AuthResult({required this.user, required this.token});
}
