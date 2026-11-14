import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber_flutter/core/network/api_client.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/core/storage/secure_storage.dart';
import 'package:saber_flutter/data/repositories/catalog_repository.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';
import 'package:saber_flutter/providers/data_providers.dart';

/// Serves canned `/providers` and `/offers` payloads that match the live API:
/// providers carry a sibling `meta` block, offers expose only `data`.
class _CatalogAdapter implements HttpClientAdapter {
  static const _providerTotal = 26;
  static const _providerPerPage = 12;

  final List<int> providerPages = [];
  final List<int> offerPages = [];
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    final page =
        int.tryParse(options.queryParameters['page']?.toString() ?? '1') ?? 1;

    if (options.path == '/providers') {
      providerPages.add(page);
      final lastPage = (_providerTotal / _providerPerPage).ceil();
      final from = (page - 1) * _providerPerPage;
      final count = (_providerTotal - from).clamp(0, _providerPerPage);
      return _json({
        'status': 'success',
        'data': [
          for (var i = 0; i < count; i++)
            {
              'id': 'prov-${from + i}',
              'business_name': 'مزود ${from + i}',
              'business_logo': null,
              'average_rating': '4.6',
              'total_reviews': 12 + from + i,
              'total_bookings': 30 + from + i,
              'is_verified': true,
              'is_available': true,
              'city': 'عدن',
              'services_count': 4,
            },
        ],
        'meta': {
          'current_page': page,
          'last_page': lastPage,
          'total': _providerTotal,
        },
      });
    }

    if (options.path == '/offers') {
      offerPages.add(page);
      final full = page == 1;
      return _json({
        'status': 'success',
        'data': [
          if (full)
            for (var i = 0; i < 12; i++)
              {
                'id': 'offer-$i',
                'title': 'عرض $i',
                'slug': 'offer-$i',
                'description': 'وصف العرض $i',
                'image': null,
                'discount_type': 'percentage',
                'discount_value': 25,
                'min_purchase': 100,
                'start_date': '2026-11-01',
                'end_date': '2026-11-30',
                'is_running': true,
              }
          else
            for (var i = 0; i < 3; i++)
              {
                'id': 'offer-x$i',
                'title': 'عرض ثابت $i',
                'discount_type': 'fixed',
                'discount_value': 50,
                'min_purchase': null,
                'start_date': null,
                'end_date': null,
                'is_running': true,
              },
        ],
      });
    }

    return _json({'status': 'success', 'data': []});
  }

  ResponseBody _json(Map<String, dynamic> body) => ResponseBody.fromString(
        jsonEncode(body),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _CatalogAdapter adapter;
  late ProviderContainer container;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    adapter = _CatalogAdapter();
    final client = ApiClient(
      dio: Dio()..httpClientAdapter = adapter,
      baseUrl: 'http://localhost/api',
      appVersion: '1.0.0+0',
      storage: SecureStorage(),
    );
    container = ProviderContainer(
      overrides: [
        catalogRepositoryProvider.overrideWithValue(
          CatalogRepository(CatalogRemoteSource(client)),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  group('Providers directory contract', () {
    const filters = (q: '', cityId: null);

    test('first page reads meta and maps services_count', () async {
      container.listen(providerDirectoryProvider(filters), (_, __) {});
      final first =
          await container.read(providerDirectoryProvider(filters).future);

      expect(first.items, hasLength(12));
      expect(first.items.first.businessName, 'مزود 0');
      expect(first.items.first.servicesCount, 4);
      expect(first.items.first.totalReviews, 12);
      expect(first.currentPage, 1);
      expect(first.hasMore, isTrue);
      expect(first.total, 26);
    });

    test('loadMore appends pages and stops on the last one', () async {
      container.listen(providerDirectoryProvider(filters), (_, __) {});
      await container.read(providerDirectoryProvider(filters).future);
      final notifier =
          container.read(providerDirectoryProvider(filters).notifier);

      await notifier.loadMore();
      var state =
          container.read(providerDirectoryProvider(filters)).value!;
      expect(state.items, hasLength(24));
      expect(state.items.last.id, 'prov-23');
      expect(state.currentPage, 2);
      expect(state.hasMore, isTrue);

      await notifier.loadMore();
      state = container.read(providerDirectoryProvider(filters)).value!;
      expect(state.items, hasLength(26));
      expect(state.currentPage, 3);
      expect(state.hasMore, isFalse);

      await notifier.loadMore();
      expect(adapter.providerPages, [1, 2, 3]);
    });

    test('city and search filters reach the query string', () async {
      const filtered = (q: 'سباكة', cityId: 'city-uuid');
      container.listen(providerDirectoryProvider(filtered), (_, __) {});
      await container.read(providerDirectoryProvider(filtered).future);

      expect(adapter.lastRequest?.queryParameters['q'], 'سباكة');
      expect(adapter.lastRequest?.queryParameters['city_id'], 'city-uuid');
      expect(adapter.lastRequest?.queryParameters['page'], 1);
      expect(adapter.lastRequest?.queryParameters['per_page'], 12);
    });
  });

  group('Offers contract', () {
    test('maps real fields and derives percentage discounts', () async {
      container.listen(offersCatalogProvider, (_, __) {});
      final first = await container.read(offersCatalogProvider.future);

      expect(first.items, hasLength(12));
      final percentage = first.items.first;
      expect(percentage.title, 'عرض 0');
      expect(percentage.slug, 'offer-0');
      expect(percentage.discountType, 'percentage');
      expect(percentage.discountPercent, 25);
      expect(percentage.minPurchase, 100);
      expect(percentage.isRunning, isTrue);
    });

    test('uses a full page as the only has-more signal', () async {
      container.listen(offersCatalogProvider, (_, __) {});
      await container.read(offersCatalogProvider.future);
      final notifier = container.read(offersCatalogProvider.notifier);

      await notifier.loadMore();
      final state = container.read(offersCatalogProvider).value!;

      expect(adapter.offerPages, [1, 2]);
      expect(state.items, hasLength(15));
      expect(state.hasMore, isFalse);

      final fixed = state.items.last;
      expect(fixed.discountType, 'fixed');
      expect(fixed.discountValue, 50);
      expect(fixed.discountPercent, isNull);
    });
  });
}
