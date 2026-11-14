import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber_flutter/core/network/api_client.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/core/storage/secure_storage.dart';
import 'package:saber_flutter/data/repositories/provider_repository.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';
import 'package:saber_flutter/modules/provider/screens/b2b_request_form_screen.dart';
import 'package:saber_flutter/modules/provider/screens/earnings_screen.dart';
import 'package:saber_flutter/modules/provider/screens/provider_dashboard_screen.dart';
import 'package:saber_flutter/modules/provider/screens/service_catalog_screen.dart';
import 'package:saber_flutter/modules/provider/screens/working_hours_screen.dart';
import 'package:saber_flutter/models/provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';

class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({'status': 'success', 'data': {}}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeDirectory extends ProviderDirectoryController {
  _FakeDirectory(this._state);

  final ProviderDirectoryState _state;

  @override
  Future<ProviderDirectoryState> build(ProviderDirectoryFilters params) async =>
      _state;
}

Widget _wrap(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Provider API wiring', () {
    late _RecordingAdapter adapter;
    late ProviderRepository repository;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      adapter = _RecordingAdapter();
      final client = ApiClient(
        dio: Dio()..httpClientAdapter = adapter,
        baseUrl: 'http://localhost/api',
        appVersion: '1.0.0+0',
        storage: SecureStorage(),
      );
      repository = ProviderRepository(ProviderRemoteSource(client));
    });

    test('availability toggle uses the dedicated toggle-available route',
        () async {
      await repository.toggleServiceAvailable('svc-1');

      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/provider/services/svc-1/toggle-available');
    });

    test('storeArea forwards numeric service_fee', () async {
      await repository.storeArea({'area_id': 'area-1', 'service_fee': 15.5});

      final request = adapter.requests.single;
      expect(request.path, '/provider/availability/areas');
      expect(request.data, {'area_id': 'area-1', 'service_fee': 15.5});
    });

    test('storePortfolio sends the extra API-supported fields', () async {
      final file = File(
          '${Directory.systemTemp.path}/portfolio_phase3_${DateTime.now().microsecondsSinceEpoch}.jpg')
        ..writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xD9]);
      addTearDown(() {
        try {
          if (file.existsSync()) file.deleteSync();
        } on FileSystemException {
          // Windows keeps a handle on the multipart source while its stream
          // is still unread by the recording adapter.
        }
      });

      await repository.storePortfolio(
        title: 'عمل',
        description: 'وصف',
        category: 'نجارة',
        completionDate: '2026-10-01',
        clientName: 'أحمد',
        location: 'عدن',
        budget: 5000,
        isFeatured: true,
        imagePath: file.path,
      );

      final request = adapter.requests.single;
      expect(request.path, '/provider/portfolio');
      final data = request.data;
      expect(data, isA<FormData>());
      final fields = Map.fromEntries((data as FormData).fields);
      expect(fields['category'], 'نجارة');
      expect(fields['completion_date'], '2026-10-01');
      expect(fields['client_name'], 'أحمد');
      expect(fields['location'], 'عدن');
      expect(fields['budget'], '5000');
      expect(fields['is_featured'], 'true');
      expect((data).files.single.key, 'image');
    });
  });

  group('Provider phase-3 screens', () {
    testWidgets('working hours lists every weekday with the API interval',
        (tester) async {
      // The screen is a lazy list; a taller surface renders all seven days.
      tester.view.physicalSize = const Size(1200, 2800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          const WorkingHoursScreen(),
          overrides: [
            providerAvailabilityProvider.overrideWith((ref) async => {
                  'working_hours': [
                    {
                      'id': 'wh-1',
                      'day_of_week': 1,
                      'start_time': '09:00:00',
                      'end_time': '17:00:00',
                      'is_active': true,
                    },
                  ],
                  'areas': <dynamic>[],
                }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الأحد'), findsOneWidget);
      expect(find.text('الاثنين'), findsOneWidget);
      expect(find.text('السبت'), findsOneWidget);
      expect(find.textContaining('09:00'), findsOneWidget);
      expect(find.textContaining('17:00'), findsOneWidget);
      // No holidays/exceptions are promised anywhere on the screen.
      expect(find.textContaining('إجازات'), findsOneWidget);
    });

    testWidgets('dashboard reads nested provider/metrics instead of zeros',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ProviderDashboardScreen(),
          overrides: [
            providerDashboardProvider.overrideWith((ref) async => {
                  'provider': {
                    'total_bookings': 12,
                    'average_rating': '4.7',
                    'is_available': true,
                  },
                  'metrics': {
                    'total_earnings': 1250.5,
                    'pending_bookings': 3,
                  },
                  'recent_bookings': <dynamic>[],
                }),
            providerBookingsProvider.overrideWith(
                (ref, params) async => <Map<String, dynamic>>[]),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('إجمالي الأرباح المدفوعة'), findsOneWidget);
      expect(find.text('1,250.50'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('4.7'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('earnings total comes from dashboard metrics', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const EarningsScreen(),
          overrides: [
            providerWalletProvider.overrideWith(
                (ref) async => {'balance': 200, 'currency': 'SAR'}),
            providerWithdrawalsProvider
                .overrideWith((ref) async => <Map<String, dynamic>>[]),
            providerDashboardProvider.overrideWith((ref) async => {
                  'provider': <String, dynamic>{},
                  'metrics': {
                    'total_earnings': 999.5,
                    'completed_bookings': 7,
                    'today_bookings': 2,
                  },
                }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('999.50'), findsOneWidget);
      expect(find.text('إجمالي الأرباح المدفوعة'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('service card toggles send only their own endpoint',
        (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      final adapter = _RecordingAdapter();
      final repository = ProviderRepository(
        ProviderRemoteSource(
          ApiClient(
            dio: Dio()..httpClientAdapter = adapter,
            baseUrl: 'http://localhost/api',
            appVersion: '1.0.0+0',
            storage: SecureStorage(),
          ),
        ),
      );
      await tester.pumpWidget(
        _wrap(
          const ServiceCatalogScreen(),
          overrides: [
            providerRepositoryProvider.overrideWithValue(repository),
            providerServicesProvider.overrideWith((ref) async => [
                  {
                    'id': 'svc-1',
                    'name': 'صيانة',
                    'price': 100,
                    'is_active': true,
                    'is_available': false,
                  },
                ]),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('مفعّلة'), findsOneWidget);
      expect(find.text('متاحة للحجز'), findsOneWidget);
      expect(find.text('استقبال حجوزات جديدة الآن'), findsOneWidget);
      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches, hasLength(2));
      expect(switches[0].value, isTrue);
      expect(switches[1].value, isFalse);

      // Availability switch only calls toggle-available.
      await tester.tap(find.byType(Switch).at(1));
      await tester.pumpAndSettle();
      expect(adapter.requests, hasLength(1));
      expect(adapter.requests.single.path,
          '/provider/services/svc-1/toggle-available');

      // Activation switch only calls toggle-active.
      await tester.tap(find.byType(Switch).at(0));
      await tester.pumpAndSettle();
      expect(adapter.requests, hasLength(2));
      expect(adapter.requests.last.path,
          '/provider/services/svc-1/toggle-active');
    });

    testWidgets('B2B form selects a provider then shows the API fields',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const B2bRequestFormScreen(),
          overrides: [
            providerProfileProvider.overrideWith(
                (ref) async => {'id': 'own-provider'}),
            providerDirectoryProvider.overrideWith(
              () => _FakeDirectory(
                const ProviderDirectoryState(
                  items: [
                    ProviderModel(
                      id: 'prov-uuid',
                      userId: 'user-uuid',
                      businessName: 'مزود التعاون',
                      city: 'عدن',
                    ),
                  ],
                  currentPage: 1,
                  hasMore: false,
                  total: 1,
                ),
              ),
            ),
            publicProviderProfileProvider.overrideWith(
              (ref, id) async => {
                'provider': {'id': id, 'business_name': 'مزود التعاون'},
                'services': [
                  {
                    'id': 'svc-9',
                    'name': 'تركيب',
                    'formatted_price': '150 ر.س',
                    'is_active': true,
                    'is_available': true,
                  },
                ],
              },
            ),
            citiesProvider.overrideWith((ref) async => <Map<String, dynamic>>[]),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('مزود التعاون'));
      await tester.pumpAndSettle();

      expect(find.text('الخدمة *'), findsOneWidget);
      expect(find.text('المدينة *'), findsOneWidget);
      expect(find.text('العنوان التفصيلي *'), findsOneWidget);
      expect(find.text('وصف الطلب *'), findsOneWidget);
      expect(find.text('إرسال الطلب'), findsOneWidget);
    });
  });
}
