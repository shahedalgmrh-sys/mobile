import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber_flutter/core/constants/api_endpoints.dart';
import 'package:saber_flutter/core/errors/failures.dart';
import 'package:saber_flutter/core/network/api_client.dart';
import 'package:saber_flutter/core/storage/secure_storage.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';

/// [HttpClientAdapter] that answers from a scripted responder and records every
/// outgoing request so retries can be asserted.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.responder);

  final ResponseBody Function(RequestOptions options, int call) responder;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return responder(options, requests.length);
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

/// Mirrors the real failure: a ~50 KB body truncated mid-escape, which throws
/// `FormatException: Invalid unicode escape` inside Dio's JSON transformer.
ResponseBody _malformedHome() => ResponseBody.fromString(
      '{"status":true,"data":{"text":"${'x' * 51600}\\uZZZZ"}}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

ResponseBody _validHome() => _json({
      'status': true,
      'message': 'OK',
      'data': {
        'categories': <Object>[],
        'featured_services': <Object>[],
      },
    }, 200);

ApiClient _client(_FakeAdapter adapter) {
  final dio = Dio()..httpClientAdapter = adapter;
  return ApiClient(
    dio: dio,
    baseUrl: 'http://localhost/api',
    appVersion: '1.0.0+0',
    storage: SecureStorage(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('CatalogRemoteSource.home malformed-body recovery', () {
    test('retries a corrupted body once and returns the valid payload',
        () async {
      final adapter = _FakeAdapter(
        (_, call) => call == 1 ? _malformedHome() : _validHome(),
      );
      final source = CatalogRemoteSource(_client(adapter));

      final response = await source.home();

      expect(adapter.requests, hasLength(2));
      expect((response.data as Map)['data']['categories'], isEmpty);
      expect(
        adapter.requests.every((r) => r.path == ApiEndpoints.home),
        isTrue,
      );
      expect(
        adapter.requests.every(
          (r) => r.headers['Connection'] == 'close',
        ),
        isTrue,
        reason: 'every attempt must use a fresh non-pooled connection',
      );
    });

    test('reports a ServerFailure after exhausting the retry budget', () async {
      final adapter = _FakeAdapter((_, __) => _malformedHome());
      final source = CatalogRemoteSource(_client(adapter));

      await expectLater(
        source.home(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.failure,
            'failure',
            isA<ServerFailure>(),
          ),
        ),
      );
      expect(adapter.requests, hasLength(10));
    });

    test('does not retry real HTTP failures', () async {
      final adapter = _FakeAdapter((_, __) => _json({'message': 'boom'}, 500));
      final source = CatalogRemoteSource(_client(adapter));

      await expectLater(source.home(), throwsA(isA<ApiException>()));
      expect(adapter.requests, hasLength(1));
    });
  });
}
