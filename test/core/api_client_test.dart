import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber_flutter/core/constants/app_headers.dart';
import 'package:saber_flutter/core/errors/failures.dart';
import 'package:saber_flutter/core/network/api_client.dart';
import 'package:saber_flutter/core/storage/secure_storage.dart';

/// Minimal [HttpClientAdapter] that returns canned responses and records the
/// last outgoing request so header injection can be asserted.
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

ResponseBody _json(Object body, int status) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

ApiClient _client(_FakeAdapter adapter, {void Function()? onUnauthorized}) {
  final dio = Dio()..httpClientAdapter = adapter;
  return ApiClient(
    dio: dio,
    baseUrl: 'http://localhost/api',
    appVersion: '1.0.0+0',
    storage: SecureStorage(),
    onUnauthorized: onUnauthorized,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('ApiClient header contract', () {
    test('sends Accept: application/json so Laravel renders JSON errors',
        () async {
      final adapter = _FakeAdapter((_) => _json({'status': true}, 200));
      final client = _client(adapter);

      await client.get('/ping');

      expect(adapter.lastRequest?.headers[AppHeaders.accept],
          Headers.jsonContentType);
      expect(adapter.lastRequest?.headers[AppHeaders.acceptLanguage], 'ar');
      expect(adapter.lastRequest?.headers[AppHeaders.xClientType], 'flutter');
      expect(adapter.lastRequest?.headers[AppHeaders.xAppVersion], '1.0.0+0');
    });

    test('attaches the bearer token when one is stored', () async {
      FlutterSecureStorage.setMockInitialValues({'auth_token': 'abc123'});
      final adapter = _FakeAdapter((_) => _json({'status': true}, 200));
      final client = _client(adapter);

      await client.get('/me');

      expect(adapter.lastRequest?.headers[AppHeaders.authorization],
          'Bearer abc123');
    });
  });

  group('ApiClient error normalization', () {
    test('maps 422 into a ValidationFailure carrying field errors', () async {
      final adapter = _FakeAdapter((_) => _json({
            'message': 'البيانات غير صحيحة',
            'errors': {
              'phone': ['رقم الجوال مطلوب'],
            },
          }, 422));
      final client = _client(adapter);

      try {
        await client.post('/register', data: const {});
        fail('expected a DioException');
      } on DioException catch (e) {
        expect(e.error, isA<ValidationFailure>());
        final failure = e.error as ValidationFailure;
        expect(failure.errors['phone'], ['رقم الجوال مطلوب']);
      }
    });

    test('maps 403/404/429/500 into a ServerFailure with the HTTP code',
        () async {
      for (final status in [403, 404, 429, 500]) {
        final adapter = _FakeAdapter((_) => _json({'message': 'x'}, status));
        final client = _client(adapter);
        try {
          await client.get('/x');
          fail('expected a DioException for $status');
        } on DioException catch (e) {
          expect(e.error, isA<ServerFailure>(), reason: 'status $status');
          expect((e.error as ServerFailure).code, status);
        }
      }
    });

    test('maps connection errors into a NetworkFailure', () async {
      final adapter = _FakeAdapter((_) => throw DioException(
            requestOptions: RequestOptions(path: '/x'),
            type: DioExceptionType.connectionError,
          ));
      final client = _client(adapter);

      try {
        await client.get('/x');
        fail('expected a DioException');
      } on DioException catch (e) {
        expect(e.error, isA<NetworkFailure>());
      }
    });

    test('clears the session and notifies on 401', () async {
      FlutterSecureStorage.setMockInitialValues({
        'auth_token': 'expired',
        'user_data': '{"id":1}',
      });
      var notified = false;
      final adapter = _FakeAdapter((_) => _json({'message': 'Unauthenticated.'}, 401));
      final client = _client(adapter, onUnauthorized: () => notified = true);

      try {
        await client.get('/me');
        fail('expected a DioException');
      } on DioException catch (e) {
        expect(e.error, isA<UnauthorizedFailure>());
      }

      expect(notified, isTrue);
      expect(await client.storage.readToken(), isNull);
      expect(await client.storage.readUser(), isNull);
    });
  });
}
