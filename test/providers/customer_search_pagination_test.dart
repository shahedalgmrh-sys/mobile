import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber_flutter/core/network/api_client.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/core/storage/secure_storage.dart';
import 'package:saber_flutter/data/repositories/customer_repository.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';
import 'package:saber_flutter/providers/data_providers.dart';

/// Serves [total] canned services split into pages of [perPage], honouring the
/// `page` query parameter and echoing the `meta` block the API returns, so the
/// whole paging contract (request → parse → accumulate) is exercised.
class _PagingAdapter implements HttpClientAdapter {
  static const int total = 32;
  static const int perPage = 15;

  final List<int> requestedPages = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final page =
        int.tryParse(options.queryParameters['page']?.toString() ?? '1') ?? 1;
    requestedPages.add(page);

    final lastPage = (total / perPage).ceil();
    final from = (page - 1) * perPage;
    final count = (total - from).clamp(0, perPage);

    return ResponseBody.fromString(
      jsonEncode({
        'status': 'success',
        'data': [
          for (var i = 0; i < count; i++)
            {
              'id': 'svc-${from + i}',
              'name': 'خدمة ${from + i}',
              'slug': 'svc-${from + i}',
              'price': 100,
            },
        ],
        'meta': {
          'current_page': page,
          'last_page': lastPage,
          'per_page': perPage,
          'total': total,
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const CustomerSearchFilters params = (
    q: '',
    categoryId: null,
    cityId: null,
    minPrice: null,
    maxPrice: null,
    minRating: null,
    sort: 'relevance',
  );

  late _PagingAdapter adapter;
  late ProviderContainer container;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    adapter = _PagingAdapter();
    final client = ApiClient(
      dio: Dio()..httpClientAdapter = adapter,
      baseUrl: 'http://localhost/api',
      appVersion: '1.0.0+0',
      storage: SecureStorage(),
    );
    container = ProviderContainer(
      overrides: [
        customerRepositoryProvider.overrideWithValue(
          CustomerRepository(CustomerRemoteSource(client)),
        ),
      ],
    );
    // Keep the autoDispose family alive for the duration of the test.
    container.listen(customerSearchProvider(params), (_, __) {});
    addTearDown(container.dispose);
  });

  test('first page exposes the API pagination metadata', () async {
    final first = await container.read(customerSearchProvider(params).future);

    expect(first.items, hasLength(15));
    expect(first.currentPage, 1);
    expect(first.lastPage, 3);
    expect(first.total, 32);
    expect(first.hasMore, isTrue);
    expect(adapter.requestedPages, [1]);
  });

  test('loadMore appends pages and stops on the last one', () async {
    await container.read(customerSearchProvider(params).future);
    final notifier = container.read(customerSearchProvider(params).notifier);

    await notifier.loadMore();
    var state = container.read(customerSearchProvider(params)).value!;
    expect(state.items, hasLength(30));
    expect(state.items.last['id'], 'svc-29');
    expect(state.currentPage, 2);
    expect(state.hasMore, isTrue);

    await notifier.loadMore();
    state = container.read(customerSearchProvider(params)).value!;
    expect(state.items, hasLength(32));
    expect(state.items.last['id'], 'svc-31');
    expect(state.currentPage, 3);
    expect(state.hasMore, isFalse);
    expect(adapter.requestedPages, [1, 2, 3]);

    // Past the last page loadMore must not fire another request.
    await notifier.loadMore();
    expect(adapter.requestedPages, [1, 2, 3]);
    expect(
      container.read(customerSearchProvider(params)).value!.items,
      hasLength(32),
    );
  });

  test('changing a filter resets to page 1', () async {
    await container.read(customerSearchProvider(params).future);
    await container.read(customerSearchProvider(params).notifier).loadMore();
    expect(
      container.read(customerSearchProvider(params)).value!.items,
      hasLength(30),
    );

    const filtered = (
      q: 'تنظيف',
      categoryId: 'cat-1',
      cityId: null,
      minPrice: null,
      maxPrice: null,
      minRating: 4.5,
      sort: 'rating',
    );
    container.listen(customerSearchProvider(filtered), (_, __) {});

    final fresh = await container.read(customerSearchProvider(filtered).future);
    expect(fresh.items, hasLength(15));
    expect(fresh.currentPage, 1);
  });
}
