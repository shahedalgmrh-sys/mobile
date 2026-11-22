import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber_flutter/core/errors/failures.dart';
import 'package:saber_flutter/core/network/api_client.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/core/storage/secure_storage.dart';
import 'package:saber_flutter/data/repositories/auth_repository.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';
import 'package:saber_flutter/providers/auth_provider.dart';

ApiClient _dummyClient() => ApiClient(
  dio: Dio(),
  baseUrl: 'http://localhost/api',
  appVersion: '1.0.0+0',
  storage: SecureStorage(),
);

class _MemoryStorage extends SecureStorage {
  String? token;
  Map<String, dynamic>? user;
  String? deviceId;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String value) async => token = value;

  @override
  Future<void> deleteToken() async => token = null;

  @override
  Future<void> writeUser(Map<String, dynamic> user) async => this.user = user;

  @override
  Future<void> deleteUser() async => user = null;

  @override
  Future<String?> readDeviceId() async => deviceId;

  @override
  Future<void> writeDeviceId(String value) async => deviceId = value;

  @override
  Future<void> deleteAll() async {
    token = null;
    user = null;
    deviceId = null;
  }
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository() : super(AuthRemoteSource(_dummyClient()));

  Map<String, dynamic> user = {
    'id': 'u-a',
    'name': 'حساب أ',
    'role': 'customer',
    'is_verified': true,
  };
  bool failMe = false;

  @override
  Future<AuthResult> login({
    required String login,
    required String password,
    String deviceName = 'flutter_app',
  }) async => AuthResult(user: user, token: 'token-a', role: 'customer');

  @override
  Future<Map<String, dynamic>> me() async {
    if (failMe) throw const ApiException(UnauthorizedFailure());
    return user;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<Map<String, dynamic>> verifyOtp(String otp) async => user;
}

class _Harness {
  _Harness() {
    container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(_dummyClient()),
        secureStorageProvider.overrideWithValue(storage),
        authRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  }

  final storage = _MemoryStorage();
  final repository = _FakeAuthRepository();
  late final ProviderContainer container;

  AuthState get state => container.read(authNotifierProvider);
  AuthNotifier get notifier => container.read(authNotifierProvider.notifier);
}

void main() {
  test('login starts a new generation; profile refresh keeps it', () async {
    final harness = _Harness();
    expect(harness.state.sessionGeneration, 0);

    expect(
      await harness.notifier.login(login: 'a', password: 'x'),
      isTrue,
    );
    expect(harness.state.sessionGeneration, 1);
    expect(harness.state.userId, 'u-a');
    expect(harness.container.read(sessionScopeProvider).key, 'u-a#1');

    await harness.notifier.refreshUser();
    expect(harness.state.sessionGeneration, 1);

    expect(await harness.notifier.verifyOtp('123456'), isTrue);
    expect(harness.state.sessionGeneration, 1);
  });

  test('logout and the next login move the generation forward', () async {
    final harness = _Harness();
    await harness.notifier.login(login: 'a', password: 'x');
    expect(harness.state.sessionGeneration, 1);

    await harness.notifier.logout();
    expect(harness.state.isAuthenticated, isFalse);
    expect(harness.state.sessionGeneration, 2);
    expect(
      harness.container.read(sessionScopeProvider).key,
      'signed-out#2',
    );

    // Same user signs in again: still a new session identity.
    await harness.notifier.login(login: 'a', password: 'x');
    expect(harness.state.sessionGeneration, 3);
    expect(harness.container.read(sessionScopeProvider).key, 'u-a#3');
  });

  test('restoring a stored session starts a new generation', () async {
    final harness = _Harness();
    harness.storage.token = 'stored-token';

    await harness.notifier.checkSession();

    expect(harness.state.isAuthenticated, isTrue);
    expect(harness.state.sessionGeneration, 1);
    expect(harness.container.read(sessionScopeProvider).key, 'u-a#1');
  });

  test('logout clears account credentials but keeps the device id', () async {
    final harness = _Harness();
    harness.storage.deviceId = 'device-1';

    await harness.notifier.login(login: 'a', password: 'x');
    expect(harness.storage.token, 'token-a');
    expect(harness.storage.user, isNotNull);

    await harness.notifier.logout();

    // Account-bound data is gone; the device identity survives so request
    // headers stay stable across sessions (no account data is retained).
    expect(harness.storage.token, isNull);
    expect(harness.storage.user, isNull);
    expect(harness.storage.deviceId, 'device-1');
  });

  test('a failed session restore signs out with a new generation', () async {
    final harness = _Harness();
    harness.storage.token = 'stored-token';
    harness.repository.failMe = true;

    await harness.notifier.checkSession();

    expect(harness.state.isAuthenticated, isFalse);
    expect(harness.state.sessionGeneration, 1);
    expect(harness.state.userId, isNull);
    expect(harness.storage.token, isNull);
  });

  test('an expired session bumps the generation only once', () async {
    final harness = _Harness();
    await harness.notifier.login(login: 'a', password: 'x');

    harness.notifier.handleSessionExpired();
    expect(harness.state.isAuthenticated, isFalse);
    expect(harness.state.sessionGeneration, 2);

    harness.notifier.handleSessionExpired();
    expect(harness.state.sessionGeneration, 2);
  });

  test('SessionScope equality tracks identity, not the same user id alone', () {
    const first = SessionScope(
      isAuthenticated: true,
      userId: 'u-a',
      generation: 1,
    );
    const refreshed = SessionScope(
      isAuthenticated: true,
      userId: 'u-a',
      generation: 1,
    );
    const secondLogin = SessionScope(
      isAuthenticated: true,
      userId: 'u-a',
      generation: 2,
    );
    const otherUser = SessionScope(
      isAuthenticated: true,
      userId: 'u-b',
      generation: 1,
    );

    expect(first, refreshed);
    expect(first.sameSession(refreshed), isTrue);
    expect(first.sameSession(secondLogin), isFalse);
    expect(first.sameSession(otherUser), isFalse);
    expect(first.key, isNot(secondLogin.key));
  });
}
