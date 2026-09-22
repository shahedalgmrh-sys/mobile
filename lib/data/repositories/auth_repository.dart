import '../sources/remote_sources.dart';
import 'parsers.dart';

class AuthResult {
  final Map<String, dynamic> user;
  final String token;
  final String role;
  final bool otpSent;

  const AuthResult({
    required this.user,
    required this.token,
    required this.role,
    this.otpSent = false,
  });
}

class AuthRepository {
  final AuthRemoteSource source;
  const AuthRepository(this.source);

  AuthResult _parseAuth(dynamic data) {
    final d = asMap(data);
    final user = asMap(d['user']);
    return AuthResult(
      user: user,
      token: str(d['token']),
      role: str(user['role'], 'customer'),
      otpSent: toBool(d['otp_sent']),
    );
  }

  Future<AuthResult> login({
    required String login,
    required String password,
    String deviceName = 'flutter_app',
  }) async {
    final res = await source.login(login, password, deviceName);
    return _parseAuth(apiData(res));
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String role,
    String deviceName = 'flutter_app',
    List<dynamic>? documentPaths,
  }) async {
    final fields = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
      'role': role,
      'device_name': deviceName,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    };
    final res = await source.register(fields);
    return _parseAuth(apiData(res));
  }

  Future<Map<String, dynamic>> me() async {
    final res = await source.me();
    return asMap(asMap(apiData(res))['user']);
  }

  Future<void> logout() => source.logout();

  Future<Map<String, dynamic>> verifyOtp(String otp) async {
    final res = await source.verifyOtp(otp);
    return asMap(asMap(apiData(res))['user']);
  }

  Future<void> resendOtp() => source.resendOtp();

  Future<void> forgotPassword(String email) => source.forgotPassword(email);

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  }) =>
      source.resetPassword({
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': password,
      });
}
