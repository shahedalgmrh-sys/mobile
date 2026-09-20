import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_status.dart';

class AuthState {
  final bool isAuthenticated;
  final String? token;
  final String? userId;
  final UserRole? role;
  final bool isProfileComplete;

  const AuthState({
    this.isAuthenticated = false,
    this.token,
    this.userId,
    this.role,
    this.isProfileComplete = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? token,
    String? userId,
    UserRole? role,
    bool? isProfileComplete,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> checkSession() async {
    await Future.delayed(const Duration(milliseconds: 300));
    state = const AuthState();
  }

  Future<void> loginWithPhone(String phone) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<bool> verifyOtp(String otp) async {
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      isAuthenticated: true,
      token: 'mock_token_$otp',
      userId: 'user_123',
      role: UserRole.customer,
      isProfileComplete: true,
    );
    return true;
  }

  Future<void> register({
    required String name,
    required String phone,
    required String password,
    String? email,
    String? city,
    UserRole role = UserRole.customer,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      token: 'mock_register_token',
      role: role,
    );
  }

  Future<void> logout() async {
    state = const AuthState();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
