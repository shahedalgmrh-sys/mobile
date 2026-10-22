import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber_flutter/core/errors/failures.dart';
import 'package:saber_flutter/core/network/api_client.dart';
import 'package:saber_flutter/core/storage/secure_storage.dart';
import 'package:saber_flutter/data/repositories/customer_repository.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';

/// Same canned-adapter pattern as `core/api_client_test.dart`.
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

CustomerRepository _repo(_FakeAdapter adapter) {
  final dio = Dio()..httpClientAdapter = adapter;
  final client = ApiClient(
    dio: dio,
    baseUrl: 'http://localhost/api',
    appVersion: '1.0.0+0',
    storage: SecureStorage(),
  );
  return CustomerRepository(CustomerRemoteSource(client));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('Wallet top-up contract (server FIN-01 flow)', () {
    test('addFunds posts amount + payment_method and unwraps the '
        'pending payment intent', () async {
      final adapter = _FakeAdapter((options) {
        expect(options.uri.path, '/api/customer/wallet/add-funds');
        expect(options.data['amount'], 250.0);
        expect(options.data['payment_method'], 'mada');
        return _json({
          'status': 'pending',
          'message': 'Payment intent created.',
          'data': {
            'payment_id': 'pay-123',
            'amount': 250.0,
            'currency': 'SAR',
            'payment_method': 'mada',
            'status': 'pending',
            'checkout_url': 'http://localhost/customer/wallet/checkout/pay-123',
          },
        }, 201);
      });
      final repo = _repo(adapter);

      final result = await repo.addFunds(250, 'mada');

      expect(result['payment_id'], 'pay-123');
      expect(result['status'], 'pending');
      expect(result['checkout_url'], isNotNull);
    });

    test('confirmWalletPayment posts to confirm-payment/{id} and returns '
        'the credited wallet', () async {
      final adapter = _FakeAdapter((options) {
        expect(options.uri.path,
            '/api/customer/wallet/confirm-payment/pay-123');
        expect(options.method, 'POST');
        return _json({
          'status': 'success',
          'message': 'Funds added successfully.',
          'data': {
            'wallet': {'balance': 250.0, 'formatted_balance': '250.00'},
            'payment': {'payment_status': 'completed'},
          },
        }, 200);
      });
      final repo = _repo(adapter);

      final result = await repo.confirmWalletPayment('pay-123');

      expect(result['wallet']['balance'], 250.0);
      expect(result['payment']['payment_status'], 'completed');
    });

    test('503 gateway-not-configured maps to a ServerFailure carrying the '
        'server message', () async {
      final adapter = _FakeAdapter((_) => _json({
            'status': 'error',
            'message': 'بوابة الدفع غير مفعلة في هذه البيئة.',
          }, 503));
      final repo = _repo(adapter);

      try {
        await repo.confirmWalletPayment('pay-123');
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.failure, isA<ServerFailure>());
        final failure = e.failure as ServerFailure;
        expect(failure.code, 503);
        expect(failure.message, 'بوابة الدفع غير مفعلة في هذه البيئة.');
      }
    });

    test('422 validation error maps to a ValidationFailure with field '
        'messages for the amount rule (min:10, max:50000)', () async {
      final adapter = _FakeAdapter((options) {
        expect(options.data['amount'], 5.0);
        return _json({
          'message': 'البيانات غير صحيحة',
          'errors': {
            'amount': ['يجب أن يكون المبلغ 10 ريال على الأقل.'],
          },
        }, 422);
      });
      final repo = _repo(adapter);

      try {
        await repo.addFunds(5, 'mada');
        fail('expected ApiException');
      } on ApiException catch (e) {
        expect(e.failure, isA<ValidationFailure>());
        final failure = e.failure as ValidationFailure;
        expect(failure.errors['amount'], hasLength(1));
      }
    });
  });
}
