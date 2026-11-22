import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber_flutter/core/errors/failures.dart';
import 'package:saber_flutter/core/network/api_client.dart';
import 'package:saber_flutter/core/storage/secure_storage.dart';
import 'package:saber_flutter/data/repositories/customer_repository.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';

ApiClient _dummyClient() => ApiClient(
  dio: Dio(),
  baseUrl: 'http://localhost/api',
  appVersion: '1.0.0+0',
  storage: SecureStorage(),
);

/// Fake transport returning the top-level toggle envelope
/// `{status, favorited, message}` used by the real API.
class _FakeFavoriteSource extends CustomerRemoteSource {
  _FakeFavoriteSource({this.body, this.error}) : super(_dummyClient());

  final Map<String, dynamic>? body;
  final Object? error;
  int serviceCalls = 0;
  int providerCalls = 0;

  Response<dynamic> _response() {
    final failure = error;
    if (failure != null) throw failure;
    return Response<dynamic>(
      requestOptions: RequestOptions(path: '/api/customer/favorites/toggle'),
      data: body,
      statusCode: 200,
    );
  }

  @override
  Future<Response<dynamic>> toggleServiceFavorite(String serviceId) async {
    serviceCalls++;
    return _response();
  }

  @override
  Future<Response<dynamic>> toggleProviderFavorite(String providerId) async {
    providerCalls++;
    return _response();
  }
}

/// Fake transport for the favorites list endpoint. The real backend answers
/// `{status, data: {services: {data: [...]}, providers: {data: [...]}}}`.
class _FakeFavoritesSource extends CustomerRemoteSource {
  _FakeFavoritesSource(this.body) : super(_dummyClient());

  final Map<String, dynamic>? body;
  int calls = 0;

  @override
  Future<Response<dynamic>> favorites() async {
    calls++;
    return Response<dynamic>(
      requestOptions: RequestOptions(path: '/api/customer/favorites'),
      data: body,
      statusCode: 200,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  CustomerRepository repositoryWith(CustomerRemoteSource source) =>
      CustomerRepository(source);

  test('service toggle returns true from the server favorited flag', () async {
    final source = _FakeFavoriteSource(
      body: {
        'status': 'success',
        'favorited': true,
        'message': 'Added to favorites.',
      },
    );

    final result = await repositoryWith(source).toggleServiceFavorite('s1');

    expect(result, isTrue);
    expect(source.serviceCalls, 1);
  });

  test('service toggle returns false from the server favorited flag', () async {
    final source = _FakeFavoriteSource(
      body: {
        'status': 'success',
        'favorited': false,
        'message': 'Removed from favorites.',
      },
    );

    final result = await repositoryWith(source).toggleServiceFavorite('s1');

    expect(result, isFalse);
    expect(source.serviceCalls, 1);
  });

  test('provider toggle returns the confirmed favorited flag', () async {
    final source = _FakeFavoriteSource(
      body: {
        'status': 'success',
        'favorited': true,
        'message': 'Provider added to favorites.',
      },
    );

    final result = await repositoryWith(source).toggleProviderFavorite('p1');

    expect(result, isTrue);
    expect(source.providerCalls, 1);
  });

  test('missing favorited is a clear protocol error', () async {
    final source = _FakeFavoriteSource(
      body: {'status': 'success', 'message': 'Added to favorites.'},
    );

    await expectLater(
      repositoryWith(source).toggleServiceFavorite('s1'),
      throwsA(isA<InvalidFavoriteResponseException>()),
    );
  });

  test('non-boolean favorited is rejected instead of guessed', () async {
    final source = _FakeFavoriteSource(
      body: {'status': 'success', 'favorited': 'true'},
    );

    await expectLater(
      repositoryWith(source).toggleProviderFavorite('p1'),
      throwsA(isA<InvalidFavoriteResponseException>()),
    );
  });

  test('the real nested favorites envelope is preserved as sent', () async {
    final source = _FakeFavoritesSource({
      'status': 'success',
      'data': {
        'services': {
          'data': [
            {'id': 's1', 'slug': 'deep-clean', 'name': 'تنظيف'},
          ],
        },
        'providers': {
          'data': [
            {'id': 'p1', 'business_name': 'مزود'},
          ],
        },
      },
    });

    final result = await repositoryWith(source).favorites();

    expect(source.calls, 1);
    // Both buckets stay resource envelopes, not flat lists.
    expect(result['services'], isA<Map<String, dynamic>>());
    expect(result['providers'], isA<Map<String, dynamic>>());
    expect(
      dataList(result['services']).map((item) => item['id']).toList(),
      ['s1'],
    );
    expect(
      dataList(result['providers']).map((item) => item['id']).toList(),
      ['p1'],
    );
  });

  test('empty nested collections parse as a known empty list', () async {
    final source = _FakeFavoritesSource({
      'status': 'success',
      'data': {
        'services': {'data': <dynamic>[]},
        'providers': {'data': <dynamic>[]},
      },
    });

    final result = await repositoryWith(source).favorites();

    expect(dataList(result['services']), isEmpty);
    expect(dataList(result['providers']), isEmpty);
  });

  test('API failure propagates without inventing a new state', () async {
    final source = _FakeFavoriteSource(
      error: const ApiException(NetworkFailure()),
    );

    await expectLater(
      repositoryWith(source).toggleServiceFavorite('s1'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.failure,
          'failure',
          isA<NetworkFailure>(),
        ),
      ),
    );
  });
}
