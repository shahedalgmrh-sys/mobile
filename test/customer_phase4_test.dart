import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/core/network/api_client.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/core/storage/secure_storage.dart';
import 'package:saber_flutter/data/repositories/catalog_repository.dart';
import 'package:saber_flutter/data/repositories/customer_repository.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';
import 'package:saber_flutter/models/app_config.dart';
import 'package:saber_flutter/modules/customer/screens/bookings/bookings_list_screen.dart';
import 'package:saber_flutter/modules/customer/screens/complaints/complaint_details_screen.dart';
import 'package:saber_flutter/modules/customer/screens/complaints_screen.dart';
import 'package:saber_flutter/modules/customer/screens/home/search_screen.dart';
import 'package:saber_flutter/modules/customer/screens/submit_complaint_screen.dart';
import 'package:saber_flutter/modules/customer/screens/support_screen.dart';
import 'package:saber_flutter/modules/customer/screens/wallet/wallet_screen.dart';
import 'package:saber_flutter/modules/customer/screens/wallet/wallet_statement_screen.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/providers/location_provider.dart';

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.body);

  final Map<String, dynamic> body;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeSearchController extends CustomerSearchController {
  CustomerSearchFilters? lastParams;

  @override
  Future<CustomerSearchState> build(CustomerSearchFilters params) async {
    lastParams = params;
    return const CustomerSearchState(
      items: [],
      currentPage: 1,
      lastPage: 1,
      total: 0,
    );
  }
}

class _FakeLocationNotifier extends AppLocationNotifier {
  @override
  Future<AppLocation?> build() async => null;
}

class _FakeCustomerRepository extends CustomerRepository {
  _FakeCustomerRepository(
    this.pages, {
    this.bookingEnvelopes = const {},
  }) : super(
          CustomerRemoteSource(
            ApiClient(
              dio: Dio(),
              baseUrl: 'http://localhost/api',
              appVersion: '1.0.0+0',
              storage: SecureStorage(),
            ),
          ),
        );

  final Map<int, Map<String, dynamic>> pages;
  final List<String?> requestedPages = [];

  /// Keyed by "<status|all>|<page>".
  final Map<String, Map<String, dynamic>> bookingEnvelopes;
  final List<(String?, int?)> bookingRequests = [];

  @override
  Future<Map<String, dynamic>> reports(String type, {String? page}) async {
    requestedPages.add(page);
    final index = page == null ? 1 : int.parse(page);
    return pages[index]!;
  }

  @override
  Future<Map<String, dynamic>> bookingsPage({String? status, int? page}) async {
    bookingRequests.add((status, page));
    return bookingEnvelopes['${status ?? 'all'}|${page ?? 1}'] ??
        <String, dynamic>{};
  }
}

class _FakeCatalogRepository extends CatalogRepository {
  _FakeCatalogRepository()
      : super(
          CatalogRemoteSource(
            ApiClient(
              dio: Dio(),
              baseUrl: 'http://localhost/api',
              appVersion: '1.0.0+0',
              storage: SecureStorage(),
            ),
          ),
        );

  final List<Map<String, dynamic>> contacts = [];

  @override
  Future<void> sendContactMessage({
    required String name,
    required String email,
    String? phone,
    required String subject,
    required String message,
  }) async {
    contacts.add({
      'name': name,
      'email': email,
      'phone': phone,
      'subject': subject,
      'message': message,
    });
  }
}

Widget _wrap(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(AppConfig.customer()),
        ...overrides,
      ],
      child: MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      ),
    );

/// Pumps a screen on a tall surface so lazily-built `ListView` children
/// (transaction rows, empty states, footers) are actually mounted.
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(1200, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_wrap(child, overrides: overrides));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('Complaints', () {
    final complaint = <String, dynamic>{
      'id': 'cmp-1',
      'complaint_number': 'CMP-1001',
      'subject': 'تأخر الفني',
      'description': 'وصل الفني متأخراً ساعتين دون إشعار.',
      'status': 'in_progress',
      'priority': 'high',
      'created_at': '2026-11-10T10:00:00Z',
      'booking': {
        'id': 'b-1',
        'booking_number': 'BK-1',
        // ComplaintResource flattens the service to its name.
        'service': 'صيانة تكييف',
      },
      'against': {'id': 'p-1', 'name': 'مزود الاختبار'},
      'messages': [
        {
          'id': 'm-2',
          'message': 'جارٍ مراجعة الشكوى مع المزود.',
          'created_at': '2026-11-10T12:00:00Z',
          'user': {'id': 'u-2', 'name': 'الدعم', 'role': 'admin'},
        },
        {
          'id': 'm-1',
          'message': 'شكراً لتواصلك، تم استلام الشكوى.',
          'created_at': '2026-11-10T11:00:00Z',
          'user': {'id': 'u-2', 'name': 'الدعم', 'role': 'admin'},
        },
      ],
    };

    testWidgets('list renders the API body, status and latest reply',
        (tester) async {
      await _pump(
        tester,
        const CustomerComplaintsScreen(),
        overrides: [
          customerComplaintsProvider.overrideWith((ref) async => [complaint]),
        ],
      );

      expect(find.text('تأخر الفني'), findsOneWidget);
      expect(find.text('وصل الفني متأخراً ساعتين دون إشعار.'), findsOneWidget);
      expect(find.text('قيد المعالجة'), findsOneWidget);
      expect(find.textContaining('رد الدعم: جارٍ مراجعة الشكوى'), findsOneWidget);
      expect(find.text('أولوية عالية'), findsOneWidget);
      expect(find.textContaining('CMP-1001'), findsOneWidget);
      expect(
        find.text('يعرض API آخر 15 شكوى — تُدار الردود والإغلاق من فريق الدعم.'),
        findsOneWidget,
      );
    });

    testWidgets('details show the thread oldest-first and the web-only limits',
        (tester) async {
      await _pump(
        tester,
        const ComplaintDetailsScreen(id: 'cmp-1'),
        overrides: [
          customerComplaintsProvider.overrideWith((ref) async => [complaint]),
        ],
      );

      expect(find.text('تفاصيل الشكوى'), findsOneWidget);
      expect(find.textContaining('صيانة تكييف'), findsOneWidget);
      expect(find.text('مزود الاختبار'), findsOneWidget);
      expect(
        find.text('شكراً لتواصلك، تم استلام الشكوى.'),
        findsOneWidget,
      );
      expect(
        find.text('جارٍ مراجعة الشكوى مع المزود.'),
        findsOneWidget,
      );
      expect(
        find.textContaining('الرد على الشكوى وإغلاقها غير متاحين عبر API'),
        findsOneWidget,
      );
    });

    testWidgets('submission sends the selected priority and opens details',
        (tester) async {
      final adapter = _RecordingAdapter({
        'status': 'success',
        'data': {'id': 'cmp-new'},
      });
      final repository = CustomerRepository(
        CustomerRemoteSource(
          ApiClient(
            dio: Dio()..httpClientAdapter = adapter,
            baseUrl: 'http://localhost/api',
            appVersion: '1.0.0+0',
            storage: SecureStorage(),
          ),
        ),
      );
      final router = GoRouter(
        initialLocation: '/new',
        routes: [
          GoRoute(path: '/new', builder: (_, __) => const SubmitComplaintScreen()),
          GoRoute(
            path: '/complaints/:id',
            builder: (_, s) =>
                Scaffold(body: Text('details:${s.pathParameters['id']}')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            customerRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('جودة منخفضة'));
      await tester.tap(find.text('عالية'));
      await tester.enterText(find.byType(TextField), 'لم يتم تنظيف المكان.');
      await tester.pump();

      await tester.tap(find.text('إرسال البلاغ'));
      await tester.pumpAndSettle();

      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/customer/complaints');
      final data = request.data as Map<String, dynamic>;
      expect(data['subject'], 'جودة منخفضة');
      expect(data['priority'], 'high');
      expect(data['description'], 'لم يتم تنظيف المكان.');
      expect(data.containsKey('booking_id'), isFalse);
      expect(find.text('details:cmp-new'), findsOneWidget);
    });
  });

  group('Search', () {
    testWidgets('defaults omit slider extremes and empty results offer reset',
        (tester) async {
      final fake = _FakeSearchController();
      await _pump(
        tester,
        const SearchScreen(),
        overrides: [
          customerSearchProvider.overrideWith(() => fake),
          categoriesProvider.overrideWith((ref) async => <CategoryItem>[]),
          citiesProvider.overrideWith((ref) async => <Map<String, dynamic>>[]),
          popularSearchesProvider.overrideWith((ref) async => <String>[]),
          appLocationProvider.overrideWith(() => _FakeLocationNotifier()),
        ],
      );

      final params = fake.lastParams;
      expect(params, isNotNull);
      expect(params!.q, '');
      expect(params.categoryId, isNull);
      expect(params.cityId, isNull);
      expect(params.minPrice, isNull);
      expect(params.maxPrice, isNull);
      expect(params.minRating, isNull);
      expect(params.latitude, isNull);
      expect(params.longitude, isNull);
      expect(params.radiusKm, isNull);
      expect(params.sort, 'relevance');

      expect(find.text('لا توجد نتائج مطابقة'), findsOneWidget);
      expect(find.text('جرّب كلمة أخرى أو خفّف الفلاتر.'), findsOneWidget);
      // One reset action inside the filter card, one in the empty state.
      expect(find.text('إعادة ضبط الفلاتر'), findsNWidgets(2));
    });
  });

  group('Wallet', () {
    testWidgets('renders real balance, totals and transaction metadata',
        (tester) async {
      await _pump(
        tester,
        const WalletScreen(),
        overrides: [
          customerWalletProvider.overrideWith(
            (ref) async => {
              'id': 'w-1',
              'balance': 1234.5,
              'pending_balance': 25,
              'total_credited': 5000,
              'total_debited': 3790.5,
              'currency': 'SAR',
              'is_active': true,
            },
          ),
          walletTransactionsProvider.overrideWith(
            (ref) async => [
              {
                'id': 't-1',
                'transaction_number': 'WT-1',
                'type': 'credit',
                'amount': 250,
                'balance_before': 984.5,
                'balance_after': 1234.5,
                'description': 'شحن رصيد المحفظة',
                'status': 'pending',
                'created_at': '2026-11-10T10:00:00Z',
              },
            ],
          ),
        ],
      );

      expect(find.text('1,234.50'), findsOneWidget);
      expect(find.text('SAR'), findsOneWidget);
      expect(find.text('25.00'), findsOneWidget);
      expect(find.text('5,000.00'), findsOneWidget);
      expect(find.text('3,790.50'), findsOneWidget);
      expect(find.text('معلّق'), findsOneWidget);
      expect(find.text('إجمالي الإيداعات'), findsOneWidget);
      expect(find.text('إجمالي الخصومات'), findsOneWidget);
      expect(find.text('شحن رصيد المحفظة'), findsOneWidget);
      expect(find.text('+250.00'), findsOneWidget);
      expect(find.text('قيد المعالجة'), findsOneWidget);
      expect(find.text('يعرض API آخر 20 عملية فقط.'), findsOneWidget);
    });

    testWidgets('offers retry for both failing calls', (tester) async {
      await _pump(
        tester,
        const WalletScreen(),
        overrides: [
          customerWalletProvider
              .overrideWith((ref) async => throw Exception('wallet')),
          walletTransactionsProvider
              .overrideWith((ref) async => throw Exception('txs')),
        ],
      );

      expect(find.text('تعذر تحميل العمليات'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsNWidgets(2));
    });

    testWidgets('statement shows summary and appends the next API page',
        (tester) async {
      Map<String, dynamic> tx(String id, String desc, num amount) => {
            'id': id,
            'type': 'debit',
            'amount': amount,
            'balance_after': 100,
            'description': desc,
            'status': 'completed',
            'created_at': '2026-11-09T09:00:00Z',
          };
      final repository = _FakeCustomerRepository({
        1: {
          'current_page': 1,
          'last_page': 2,
          'total': 3,
          'data': [tx('t-1', 'دفع حجز', 50), tx('t-2', 'استرداد', 20)],
        },
        2: {
          'current_page': 2,
          'last_page': 2,
          'total': 3,
          'data': [tx('t-3', 'سحب رصيد', 10)],
        },
      });

      await _pump(
        tester,
        const WalletStatementScreen(),
        overrides: [
          customerRepositoryProvider.overrideWithValue(repository),
          customerWalletProvider.overrideWith(
            (ref) async => {
              'id': 'w-1',
              'balance': 1234.5,
              'pending_balance': 0,
              'total_credited': 5000,
              'total_debited': 3790.5,
              'currency': 'SAR',
            },
          ),
        ],
      );

      expect(repository.requestedPages, [null]);
      expect(find.text('1,234.50 SAR'), findsOneWidget);
      expect(find.text('دفع حجز'), findsOneWidget);
      expect(find.text('استرداد'), findsOneWidget);
      expect(find.text('عرض 2 من 3'), findsOneWidget);

      await tester.tap(find.text('تحميل المزيد'));
      await tester.pumpAndSettle();

      expect(repository.requestedPages, [null, '2']);
      expect(find.text('سحب رصيد'), findsOneWidget);
      expect(find.text('عرض 3 من 3'), findsOneWidget);
      expect(find.text('تم عرض كل العمليات'), findsOneWidget);
    });
  });

  group('Bookings', () {
    Map<String, dynamic> booking(String id, String number, String status) => {
          'id': id,
          'booking_number': number,
          'status': status,
          'booking_date': '2026-11-10T10:00:00Z',
          'total': 150,
          'service': {'name': 'تنظيف منزل'},
        };

    testWidgets('tabs use real statuses and append the next API page',
        (tester) async {
      final repository = _FakeCustomerRepository(
        const {},
        bookingEnvelopes: {
          'all|1': {
            'data': [booking('b-1', '1001', 'pending')],
            'meta': {'current_page': 1, 'last_page': 2, 'total': 2},
          },
          'all|2': {
            'data': [booking('b-2', '1002', 'completed')],
            'meta': {'current_page': 2, 'last_page': 2, 'total': 2},
          },
        },
      );

      await _pump(
        tester,
        const BookingsListScreen(),
        overrides: [customerRepositoryProvider.overrideWithValue(repository)],
      );

      // "upcoming" is not a stored status; the tab must not send it.
      expect(find.text('القادمة'), findsNothing);
      expect(repository.bookingRequests.first, (null, null));
      expect(find.textContaining('BK-1001'), findsOneWidget);

      await tester.tap(find.text('تحميل المزيد'));
      await tester.pumpAndSettle();

      expect(repository.bookingRequests, contains((null, 2)));
      expect(find.textContaining('BK-1002'), findsOneWidget);
      expect(find.text('تم عرض جميع الحجوزات (2)'), findsOneWidget);
    });
  });

  group('Support', () {
    testWidgets('requires a real email instead of a fabricated fallback',
        (tester) async {
      final repository = _FakeCatalogRepository();
      await _pump(
        tester,
        const SupportScreen(),
        overrides: [
          catalogRepositoryProvider.overrideWithValue(repository),
          faqsProvider.overrideWith((ref) async => <Map<String, dynamic>>[]),
        ],
      );

      await tester.enterText(find.byType(TextField).at(0), 'مشكلة في الدفع');
      await tester.enterText(find.byType(TextField).at(2), 'لم يصل المبلغ.');
      await tester.tap(find.text('إرسال'));
      await tester.pumpAndSettle();

      expect(repository.contacts, isEmpty);
      expect(
        find.text('أدخل بريدًا إلكترونيًا صالحًا للرد عليك'),
        findsOneWidget,
      );

      await tester.enterText(
          find.byType(TextField).at(1), 'client@example.com');
      await tester.tap(find.text('إرسال'));
      await tester.pumpAndSettle();

      expect(repository.contacts, hasLength(1));
      expect(repository.contacts.single['email'], 'client@example.com');
      expect(repository.contacts.single['subject'], 'مشكلة في الدفع');
    });
  });
}
