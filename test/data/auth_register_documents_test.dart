import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber_flutter/core/network/api_client.dart';
import 'package:saber_flutter/core/storage/secure_storage.dart';
import 'package:saber_flutter/data/repositories/auth_repository.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';

/// Same canned-adapter pattern as `data/customer_wallet_flows_test.dart`.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.responder);

  final ResponseBody Function(RequestOptions options) responder;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return responder(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _createdProviderResponse() => ResponseBody.fromString(
      jsonEncode({
        'status': 'success',
        'message': 'Registration successful.',
        'data': {
          'user': {
            'id': 20,
            'name': 'فهد السبيعي',
            'email': 'provider@example.com',
            'role': 'provider',
            'account_status': 'pending',
            'is_verified': false,
            'provider_profile': {'is_verified': false},
          },
          'token': '1|abc',
          'otp_sent': true,
        },
      }),
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

AuthRepository _repo(_FakeAdapter adapter) {
  final dio = Dio()..httpClientAdapter = adapter;
  final client = ApiClient(
    dio: dio,
    baseUrl: 'http://localhost/api',
    appVersion: '1.0.0+0',
    storage: SecureStorage(),
  );
  return AuthRepository(AuthRemoteSource(client));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('Provider registration documents contract', () {
    late Directory tempDir;
    late File document;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('saber_docs_');
      document = File('${tempDir.path}/license.pdf');
      await document.writeAsBytes([0x25, 0x50, 0x44, 0x46]);
    });

    tearDown(() async {
      // MultipartFile keeps the handle open until the request stream is done;
      // cleanup is best-effort so it never fails the assertions.
      try {
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      } on FileSystemException {
        // OS temp folder cleans this up later.
      }
    });

    test('sends documents[] as multipart files when paths are provided',
        () async {
      final adapter = _FakeAdapter((options) {
        expect(options.uri.path, '/api/auth/register');
        expect(options.method, 'POST');
        expect(
          options.headers[Headers.contentTypeHeader],
          contains('multipart/form-data'),
        );

        final form = options.data as FormData;
        final fields = {
          for (final entry in form.fields) entry.key: entry.value,
        };
        expect(fields['role'], 'provider');
        expect(fields['name'], 'فهد السبيعي');
        expect(fields['email'], 'provider@example.com');
        expect(fields['password_confirmation'], 'Password123!');
        // Fields ignored by the backend must never be sent.
        expect(fields.containsKey('business_name'), isFalse);
        expect(fields.containsKey('national_id_or_cr'), isFalse);

        expect(form.files, hasLength(1));
        expect(form.files.single.key, 'documents[]');
        expect(form.files.single.value.filename, 'license.pdf');

        return _createdProviderResponse();
      });
      final repo = _repo(adapter);

      final result = await repo.register(
        name: 'فهد السبيعي',
        email: 'provider@example.com',
        password: 'Password123!',
        role: 'provider',
        documentPaths: [document.path],
      );

      expect(result.role, 'provider');
      expect(result.otpSent, isTrue);
      expect(result.token, '1|abc');
    });

    test('keeps the JSON payload when no documents are selected', () async {
      final adapter = _FakeAdapter((options) {
        expect(options.uri.path, '/api/auth/register');
        expect(options.data, isA<Map<String, dynamic>>());
        final payload = options.data as Map<String, dynamic>;
        expect(payload['role'], 'provider');
        expect(payload.containsKey('documents[]'), isFalse);
        return _createdProviderResponse();
      });
      final repo = _repo(adapter);

      final result = await repo.register(
        name: 'فهد السبيعي',
        email: 'provider@example.com',
        password: 'Password123!',
        role: 'provider',
      );

      expect(result.role, 'provider');
    });
  });
}
