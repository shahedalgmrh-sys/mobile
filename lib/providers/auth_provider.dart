import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/failures.dart';
import '../core/providers.dart';
import '../core/storage/secure_storage.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/parsers.dart';
import '../data/sources/remote_sources.dart';
import 'package:saber_flutter/core/constants/enums.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? token;
  final String? userId;
  final UserRole? role;
  final bool isVerified;
  final bool isProfileComplete;
  final Map<String, dynamic>? user;
  final String? errorMessage;

  /// Monotonic login-session counter.
  ///
  /// It starts a new value on every successful login/registration/session
  /// restore and on every sign-out or expired session, and is never reset.
  /// Account-scoped providers use it (together with [userId]) to recognize
  /// results that belong to a previous session — including an old request
  /// that finishes after the same user logged in again.
  final int sessionGeneration;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.token,
    this.userId,
    this.role,
    this.isVerified = false,
    this.isProfileComplete = false,
    this.user,
    this.errorMessage,
    this.sessionGeneration = 0,
  });

  /// Provider approval state comes from the API's `provider_profile`
  /// (`is_verified`, and `verification_status` when present). Email
  /// verification (`isVerified`) is a separate flag and must not be used as
  /// a substitute for accreditation.
  bool get needsProviderVerification {
    if (role != UserRole.provider) return false;
    final profile = user?['provider_profile'];
    if (profile is! Map) return true;
    final map = Map<String, dynamic>.from(profile);
    final status = str(map['verification_status']).toLowerCase();
    final verified = toBool(map['is_verified']) ||
        status == 'verified' ||
        status == 'approved';
    return !verified;
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? token,
    String? userId,
    UserRole? role,
    bool? isVerified,
    bool? isProfileComplete,
    Map<String, dynamic>? user,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
    int? sessionGeneration,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      sessionGeneration: sessionGeneration ?? this.sessionGeneration,
    );
  }
}

/// Identity of the account session that owns a piece of data.
///
/// Unlike a user id it changes on *every* sign-in, so a delayed response from
/// an earlier session of the same user is still recognized as stale.
class SessionScope {
  const SessionScope({
    required this.isAuthenticated,
    this.userId,
    this.role,
    this.generation = 0,
  });

  factory SessionScope.of(AuthState state) => SessionScope(
    isAuthenticated: state.isAuthenticated,
    userId: state.userId,
    role: state.role,
    generation: state.sessionGeneration,
  );

  final bool isAuthenticated;
  final String? userId;
  final UserRole? role;
  final int generation;

  bool get hasSession =>
      isAuthenticated && userId != null && userId!.isNotEmpty;

  bool sameSession(SessionScope other) =>
      isAuthenticated == other.isAuthenticated &&
      generation == other.generation &&
      userId == other.userId;

  /// Stable key that changes on logout, account switch and same-user relogin.
  String get key => hasSession ? '$userId#$generation' : 'signed-out#$generation';

  @override
  bool operator ==(Object other) =>
      other is SessionScope && sameSession(other);

  @override
  int get hashCode => Object.hash(isAuthenticated, userId, generation);
}

/// Current account session, re-evaluated only when identity changes (not on
/// loading/error flags), so account-scoped providers rebuild exactly once per
/// login/logout.
final sessionScopeProvider = Provider<SessionScope>(
  (ref) => ref.watch(authNotifierProvider.select(SessionScope.of)),
);

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier(ref);
  // Whenever the API rejects the session (HTTP 401) the client clears the
  // stored token and notifies here so the router routes back to /login.
  ref.read(apiClientProvider).onUnauthorized = notifier.handleSessionExpired;
  return notifier;
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  AuthNotifier(this.ref) : super(const AuthState());

  SecureStorage get _storage => ref.read(secureStorageProvider);
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  String _failureMessage(Object e) {
    if (e is ApiException) {
      final f = e.failure;
      if (f is ValidationFailure) {
        return f.errors.values.expand((l) => l).join('\n');
      }
      if (f is ServerFailure) return f.message;
      if (f is NetworkFailure) return 'تعذر الاتصال بالخادم. تحقق من الشبكة.';
      if (f is UnauthorizedFailure) return 'انتهت الجلسة. سجّل الدخول مجدداً.';
    }
    return 'حدث خطأ غير متوقع.';
  }

  Future<void> _persistAuth(AuthResult result) async {
    await _storage.writeToken(result.token);
    await _storage.writeUser(result.user);
  }

  /// Signs the app out locally while keeping the session counter monotonic;
  /// every already-running request becomes stale from this point on.
  void _setSignedOut({String? errorMessage}) {
    state = AuthState(
      sessionGeneration: state.sessionGeneration + 1,
      errorMessage: errorMessage,
    );
  }

  /// [newSession] starts a new identity (login, registration, restored
  /// session); refreshes of the same identity must not change it.
  void _applyUser(
    Map<String, dynamic> user, {
    String? token,
    bool newSession = false,
  }) {
    final roleStr = str(user['role'], 'customer');
    final role = roleStr == 'provider' ? UserRole.provider : UserRole.customer;
    final verified = toBool(user['is_verified'] ?? user['email_verified_at'] != null);
    state = state.copyWith(
      isAuthenticated: true,
      token: token ?? state.token,
      userId: str(user['id']),
      role: role,
      isVerified: verified,
      isProfileComplete: true,
      user: user,
      clearError: true,
      sessionGeneration:
          newSession ? state.sessionGeneration + 1 : state.sessionGeneration,
    );
  }

  /// Restore session from stored token; validates it against /auth/user.
  Future<void> checkSession() async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) {
      _setSignedOut();
      return;
    }
    try {
      final user = await _repo.me();
      if (user.isEmpty) throw const ApiException(UnauthorizedFailure());
      await _storage.writeUser(user);
      _applyUser(user, token: token, newSession: true);
    } catch (_) {
      await _storage.deleteToken();
      await _storage.deleteUser();
      _setSignedOut();
    }
  }

  Future<bool> login({
    required String login,
    required String password,
    String? deviceName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repo.login(
        login: login,
        password: password,
        deviceName: deviceName ?? 'flutter_app',
      );
      await _persistAuth(result);
      _applyUser(result.user, token: result.token, newSession: true);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _failureMessage(e));
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required UserRole role,
    String? deviceName,
    List<String>? documentPaths,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repo.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role == UserRole.provider ? 'provider' : 'customer',
        deviceName: deviceName ?? 'flutter_app',
        documentPaths: documentPaths,
      );
      await _persistAuth(result);
      _applyUser(result.user, token: result.token, newSession: true);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _failureMessage(e));
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.verifyOtp(otp);
      await _storage.writeUser(user);
      _applyUser(user);
      state = state.copyWith(isLoading: false, isVerified: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _failureMessage(e));
      return false;
    }
  }

  Future<bool> resendOtp() async {
    try {
      await _repo.resendOtp();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _failureMessage(e));
      return false;
    }
  }

  Future<String?> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.forgotPassword(email);
      state = state.copyWith(isLoading: false);
      return null;
    } catch (e) {
      final msg = _failureMessage(e);
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return msg;
    }
  }

  /// Consumes the token from the reset email together with the new password.
  /// Returns `null` on success or a localized failure message.
  Future<String?> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.resetPassword(email: email, token: token, password: password);
      state = state.copyWith(isLoading: false);
      return null;
    } catch (e) {
      final msg = _failureMessage(e);
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return msg;
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await _repo.me();
      if (user.isNotEmpty) {
        await _storage.writeUser(user);
        _applyUser(user);
      }
    } catch (_) {}
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
    } catch (_) {}
    // Keep the stable device id so headers stay consistent across sessions.
    await _storage.deleteToken();
    await _storage.deleteUser();
    _setSignedOut();
  }

  /// Invoked by the API client when a request is rejected with HTTP 401.
  /// Clears the local session without calling the backend (the token is
  /// already invalid) and lets the router redirect to the login screen.
  void handleSessionExpired() {
    if (!state.isAuthenticated && state.token == null) return;
    _setSignedOut(errorMessage: 'انتهت الجلسة. سجّل الدخول مجدداً.');
  }
}
