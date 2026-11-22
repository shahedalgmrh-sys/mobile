import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber_flutter/core/constants/enums.dart';
import 'package:saber_flutter/core/errors/failures.dart';
import 'package:saber_flutter/core/network/api_client.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/core/storage/secure_storage.dart';
import 'package:saber_flutter/data/repositories/customer_repository.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';
import 'package:saber_flutter/models/service.dart';
import 'package:saber_flutter/modules/customer/screens/address_book_screen.dart';
import 'package:saber_flutter/modules/customer/screens/bookings/booking_details_screen.dart';
import 'package:saber_flutter/modules/customer/screens/bookings/booking_wizard_screen.dart';
import 'package:saber_flutter/modules/customer/screens/notifications/notifications_screen.dart';
import 'package:saber_flutter/modules/customer/screens/settings_screen.dart';
import 'package:saber_flutter/modules/customer/screens/submit_complaint_screen.dart';
import 'package:saber_flutter/modules/customer/screens/wallet/wallet_screen.dart';
import 'package:saber_flutter/modules/customer/screens/write_review_screen.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';

ApiClient _dummyClient() => ApiClient(
  dio: Dio(),
  baseUrl: 'http://localhost/api',
  appVersion: '1.0.0+0',
  storage: SecureStorage(),
);

/// Repository whose data, failures and delays are addressed per account, so a
/// test can replay exactly the out-of-order responses the real app can see.
class _FakeCustomerRepository extends CustomerRepository {
  _FakeCustomerRepository() : super(CustomerRemoteSource(_dummyClient()));

  String account = 'signed-out';

  final Map<String, Object?> values = {};
  final Map<String, Object> errors = {};
  final Map<String, List<Completer<Object?>>> gates = {};
  final List<String> requests = [];

  static String key(String account, String method, [String? arg]) =>
      '$account|$method|${arg ?? ''}';

  void setValue(String account, String method, String? arg, Object? value) =>
      values[key(account, method, arg)] = value;

  void failWith(String account, String method, String? arg, Object error) =>
      errors[key(account, method, arg)] = error;

  Completer<Object?> gate(String account, String method, String? arg) {
    final completer = Completer<Object?>();
    gates.putIfAbsent(key(account, method, arg), () => []).add(completer);
    return completer;
  }

  Future<T> _respond<T>(String method, [String? arg]) async {
    final requestKey = key(account, method, arg);
    requests.add(requestKey);

    final error = errors[requestKey];
    if (error != null) throw error;

    final queue = gates[requestKey];
    final Object? value = (queue != null && queue.isNotEmpty)
        ? await queue.removeAt(0).future
        : values[requestKey];
    return value as T;
  }

  // ---- read endpoints ----------------------------------------------------
  @override
  Future<Map<String, dynamic>> me() =>
      _respond<Map<String, dynamic>>('me');

  @override
  Future<List<Map<String, dynamic>>> addresses() =>
      _respond<List<Map<String, dynamic>>>('addresses');

  @override
  Future<List<Map<String, dynamic>>> bookings({String? status, int? page}) =>
      _respond<List<Map<String, dynamic>>>('bookings', status);

  @override
  Future<Map<String, dynamic>> bookingsPage({String? status, int? page}) =>
      _respond<Map<String, dynamic>>('bookingsPage');

  @override
  Future<Map<String, dynamic>> booking(String id) =>
      _respond<Map<String, dynamic>>('booking', id);

  @override
  Future<Map<String, dynamic>> trackBooking(String id) =>
      _respond<Map<String, dynamic>>('trackBooking', id);

  @override
  Future<List<Map<String, dynamic>>> payments({String? page}) =>
      _respond<List<Map<String, dynamic>>>('payments');

  @override
  Future<Map<String, dynamic>> invoice(String paymentId) =>
      _respond<Map<String, dynamic>>('invoice', paymentId);

  @override
  Future<Map<String, dynamic>> wallet() =>
      _respond<Map<String, dynamic>>('wallet');

  @override
  Future<List<Map<String, dynamic>>> walletTransactions({String? page}) =>
      _respond<List<Map<String, dynamic>>>('walletTransactions');

  @override
  Future<Map<String, dynamic>> favorites() =>
      _respond<Map<String, dynamic>>('favorites');

  @override
  Future<List<Map<String, dynamic>>> reviews() =>
      _respond<List<Map<String, dynamic>>>('reviews');

  @override
  Future<List<Map<String, dynamic>>> complaints() =>
      _respond<List<Map<String, dynamic>>>('complaints');

  @override
  Future<List<Map<String, dynamic>>> conversations() =>
      _respond<List<Map<String, dynamic>>>('conversations');

  @override
  Future<List<Map<String, dynamic>>> notifications({String? page}) =>
      _respond<List<Map<String, dynamic>>>('notifications');

  @override
  Future<int> unreadNotificationsCount() =>
      _respond<int>('unreadNotificationsCount');

  @override
  Future<List<Map<String, dynamic>>> coupons() =>
      _respond<List<Map<String, dynamic>>>('coupons');

  // ---- write endpoints ---------------------------------------------------
  Completer<Map<String, dynamic>>? reviewGate;
  final Map<String, List<Completer<void>>> markReadGates = {};
  final List<String> reviewRequests = [];
  final List<String> markReadRequests = [];

  @override
  Future<Map<String, dynamic>> storeReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    reviewRequests.add(key(account, 'storeReview', bookingId));
    final gate = reviewGate;
    if (gate != null) return gate.future;
    return {'id': 'review-1', 'rating': rating};
  }

  @override
  Future<void> markNotificationRead(String id) async {
    markReadRequests.add(key(account, 'markNotificationRead', id));
    final queue = markReadGates[key(account, 'markNotificationRead', id)];
    if (queue != null && queue.isNotEmpty) {
      await queue.removeAt(0).future;
    }
  }

  // ---- additional read/write endpoints used by the closeout suite -------
  final Map<String, List<Completer<Object?>>> writeGates = {};
  final List<String> writeRequests = [];
  final List<String> slotRequests = [];

  Completer<Object?> writeGate(String account, String method, [String? arg]) {
    final completer = Completer<Object?>();
    writeGates.putIfAbsent(key(account, method, arg), () => []).add(completer);
    return completer;
  }

  Future<Map<String, dynamic>> _writeMap(
    String method, [
    String? arg,
  ]) async {
    final requestKey = key(account, method, arg);
    writeRequests.add(requestKey);
    final queue = writeGates[requestKey];
    final Object? value = (queue != null && queue.isNotEmpty)
        ? await queue.removeAt(0).future
        : values[requestKey];
    return value is Map<String, dynamic> ? value : <String, dynamic>{};
  }

  Future<void> _writeVoid(String method, [String? arg]) async {
    final requestKey = key(account, method, arg);
    writeRequests.add(requestKey);
    final queue = writeGates[requestKey];
    if (queue != null && queue.isNotEmpty) {
      await queue.removeAt(0).future;
    }
  }

  @override
  Future<Map<String, dynamic>> conversation(String id) =>
      _respond<Map<String, dynamic>>('conversation', id);

  @override
  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> data) =>
      _writeMap('createBooking');

  @override
  Future<List<Map<String, dynamic>>> availableSlots({
    String? serviceId,
    String? service,
    required String date,
  }) async {
    slotRequests.add(key(account, 'availableSlots', date));
    return <Map<String, dynamic>>[
      <String, dynamic>{'time': '09:00', 'label_ar': '9:00 ص'},
    ];
  }

  @override
  Future<Map<String, dynamic>> cancelBooking(String id, String reason) =>
      _writeMap('cancelBooking', id);

  @override
  Future<Map<String, dynamic>> rescheduleBooking(
    String id,
    String date,
    String time, {
    String? reason,
  }) => _writeMap('rescheduleBooking', id);

  @override
  Future<Map<String, dynamic>> rebook(String id) => _writeMap('rebook', id);

  @override
  Future<Map<String, dynamic>> payBooking(String id, String method) =>
      _writeMap('payBooking', id);

  @override
  Future<Map<String, dynamic>> addFunds(double amount, String method) =>
      _writeMap('addFunds');

  @override
  Future<Map<String, dynamic>> confirmWalletPayment(String paymentId) =>
      _writeMap('confirmWalletPayment', paymentId);

  @override
  Future<Map<String, dynamic>> storeAddress(Map<String, dynamic> data) =>
      _writeMap('storeAddress');

  @override
  Future<Map<String, dynamic>> updateAddress(
    String id,
    Map<String, dynamic> data,
  ) => _writeMap('updateAddress', id);

  @override
  Future<void> destroyAddress(String id) => _writeVoid('destroyAddress', id);

  @override
  Future<Map<String, dynamic>> storeComplaint({
    String? bookingId,
    required String subject,
    required String description,
    String priority = 'medium',
  }) => _writeMap('storeComplaint');

  @override
  Future<Map<String, dynamic>> sendMessage(String id, String body) =>
      _writeMap('sendMessage', id);

  @override
  Future<void> changePassword(
    String current,
    String password,
    String confirmation,
  ) => _writeVoid('changePassword');

  @override
  Future<void> destroyAccount(String password) =>
      _writeVoid('destroyAccount');
}

const _signedOut = SessionScope(isAuthenticated: false, generation: 0);
const _accountA1 = SessionScope(
  isAuthenticated: true,
  userId: 'u-a',
  generation: 1,
);
const _accountB1 = SessionScope(
  isAuthenticated: true,
  userId: 'u-b',
  generation: 2,
);
const _accountA2 = SessionScope(
  isAuthenticated: true,
  userId: 'u-a',
  generation: 3,
);

final _testSessionProvider = StateProvider<SessionScope>((ref) => _signedOut);

ProviderContainer _newContainer(
  _FakeCustomerRepository repository, {
  List<Override> extra = const [],
}) {
  final container = ProviderContainer(
    overrides: [
      customerRepositoryProvider.overrideWithValue(repository),
      sessionScopeProvider.overrideWith(
        (ref) => ref.watch(_testSessionProvider),
      ),
      ...extra,
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void _switchTo(
  ProviderContainer container,
  _FakeCustomerRepository repository,
  SessionScope scope,
) {
  repository.account = scope.userId ?? 'signed-out';
  container.read(_testSessionProvider.notifier).state = scope;
}

Future<void> _flush() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

Widget _screen(ProviderContainer container, Widget child) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        // The customer screens resolve their labels from the ambient locale,
        // so the tests must run under the app's Arabic locale.
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

Future<void> _pumpFrames(WidgetTester tester, [int count = 3]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump();
  }
}

/// Bottom sheets and settings lists are taller than the default 800x600 test
/// surface; use a phone-sized 600x1200 logical viewport so every control is
/// laid out (and tappable) without changing app code.
void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// `SettingsScreen` wraps its `ListTile`s in a decorated box, which makes the
/// framework emit a debug-only "ink splashes may be invisible" assertion on
/// every frame. It is unrelated to session isolation (and reported separately
/// in the closeout notes), so these tests ignore exactly that diagnostic.
void _ignoreListTileInkWarning() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains(
      'ListTile background color or ink splashes may be invisible',
    )) {
      return;
    }
    previous?.call(details);
  };
  addTearDown(() {
    FlutterError.onError = previous;
  });
}

Future<void> _waitForWrite(
  WidgetTester tester,
  _FakeCustomerRepository repository,
  String method,
) async {
  for (var i = 0; i < 30; i++) {
    if (repository.writeRequests.any((key) => key.contains('|$method|'))) {
      return;
    }
    await tester.pump();
  }
}

int _readCount(_FakeCustomerRepository repository, String key) =>
    repository.requests.where((request) => request == key).length;

Map<String, dynamic> _bookingPayload(String marker, {
  String status = 'pending',
  bool paid = false,
}) => <String, dynamic>{
  'id': 'bk-1',
  'status': status,
  'is_paid': paid,
  'marker': marker,
  'booking_date': '2027-01-01',
  'booking_time': '09:00',
  'total': 100,
  'currency': 'SAR',
  'service': <String, dynamic>{'name': 'تنظيف', 'marker': marker},
  'provider': <String, dynamic>{
    'business_name': 'مزود الخدمة',
    'user': <String, dynamic>{'name': 'مزود الخدمة', 'phone': '0500000000'},
  },
  'address': <String, dynamic>{'full_address': 'عنوان $marker'},
};

class _CountingAuthNotifier extends AuthNotifier {
  _CountingAuthNotifier(super.ref) {
    state = const AuthState(
      isAuthenticated: true,
      userId: 'u-a',
      role: UserRole.customer,
      sessionGeneration: 1,
    );
  }

  int logoutCalls = 0;

  @override
  Future<void> logout() async {
    logoutCalls++;
  }
}

/// Everything the table-driven suite needs to exercise one account-scoped
/// provider end to end: how its repository answers, what the provider should
/// show, and how to read its current state.
class _Probe {
  const _Probe({
    required this.name,
    required this.method,
    this.arg,
    required this.repositoryValue,
    required this.expected,
    required this.emptyValue,
    required this.isEmpty,
    required this.state,
    required this.hold,
  });

  final String name;
  final String method;
  final String? arg;
  final Object Function(String label) repositoryValue;
  final Object Function(String label) expected;
  final Object emptyValue;
  final bool Function(Object? value) isEmpty;
  final AsyncValue<Object?> Function(ProviderContainer) state;
  final void Function(ProviderContainer) hold;

  String requestKey(String account) =>
      _FakeCustomerRepository.key(account, method, arg);
}

_Probe _mapProbe({
  required String name,
  required String method,
  String? arg,
  required AsyncValue<Object?> Function(ProviderContainer) state,
  required void Function(ProviderContainer) hold,
}) => _Probe(
  name: name,
  method: method,
  arg: arg,
  repositoryValue: (label) => <String, dynamic>{'marker': label},
  expected: (label) => <String, dynamic>{'marker': label},
  emptyValue: const <String, dynamic>{},
  isEmpty: (value) => value is Map && value.isEmpty,
  state: state,
  hold: hold,
);

_Probe _listProbe({
  required String name,
  required String method,
  String? arg,
  required AsyncValue<Object?> Function(ProviderContainer) state,
  required void Function(ProviderContainer) hold,
}) => _Probe(
  name: name,
  method: method,
  arg: arg,
  repositoryValue: (label) => <Map<String, dynamic>>[
    <String, dynamic>{'marker': label},
  ],
  expected: (label) => <Map<String, dynamic>>[
    <String, dynamic>{'marker': label},
  ],
  emptyValue: const <Map<String, dynamic>>[],
  isEmpty: (value) => value is List && value.isEmpty,
  state: state,
  hold: hold,
);

int _totalFor(String label) => switch (label) {
  'A' => 7,
  'B' => 9,
  'A-new' => 11,
  'A-old' => 13,
  _ => 0,
};

int _unreadFor(String label) => switch (label) {
  'A' => 3,
  'B' => 5,
  'A-new' => 6,
  'A-old' => 8,
  _ => 0,
};

List<_Probe> _probes() => [
  _mapProbe(
    name: 'customerMeProvider',
    method: 'me',
    state: (container) => container.read(customerMeProvider),
    hold: (container) => container.listen(customerMeProvider, (_, __) {}),
  ),
  _listProbe(
    name: 'customerAddressesProvider',
    method: 'addresses',
    state: (container) => container.read(customerAddressesProvider),
    hold: (container) =>
        container.listen(customerAddressesProvider, (_, __) {}),
  ),
  _listProbe(
    name: 'customerBookingsProvider',
    method: 'bookings',
    state: (container) => container.read(customerBookingsProvider(null)),
    hold: (container) =>
        container.listen(customerBookingsProvider(null), (_, __) {}),
  ),
  _Probe(
    name: 'customerBookingsTotalProvider',
    method: 'bookingsPage',
    repositoryValue: (label) => <String, dynamic>{
      'data': <dynamic>[
        <String, dynamic>{'marker': label},
      ],
      'meta': <String, dynamic>{'total': _totalFor(label)},
    },
    expected: _totalFor,
    emptyValue: 0,
    isEmpty: (value) => value == 0,
    state: (container) => container.read(customerBookingsTotalProvider),
    hold: (container) =>
        container.listen(customerBookingsTotalProvider, (_, __) {}),
  ),
  _mapProbe(
    name: 'customerBookingProvider',
    method: 'booking',
    arg: 'bk-1',
    state: (container) => container.read(customerBookingProvider('bk-1')),
    hold: (container) =>
        container.listen(customerBookingProvider('bk-1'), (_, __) {}),
  ),
  _mapProbe(
    name: 'bookingTrackProvider',
    method: 'trackBooking',
    arg: 'bk-1',
    state: (container) => container.read(bookingTrackProvider('bk-1')),
    hold: (container) =>
        container.listen(bookingTrackProvider('bk-1'), (_, __) {}),
  ),
  _listProbe(
    name: 'customerPaymentsProvider',
    method: 'payments',
    state: (container) => container.read(customerPaymentsProvider),
    hold: (container) =>
        container.listen(customerPaymentsProvider, (_, __) {}),
  ),
  _mapProbe(
    name: 'paymentInvoiceProvider',
    method: 'invoice',
    arg: 'pay-1',
    state: (container) => container.read(paymentInvoiceProvider('pay-1')),
    hold: (container) =>
        container.listen(paymentInvoiceProvider('pay-1'), (_, __) {}),
  ),
  _mapProbe(
    name: 'customerWalletProvider',
    method: 'wallet',
    state: (container) => container.read(customerWalletProvider),
    hold: (container) => container.listen(customerWalletProvider, (_, __) {}),
  ),
  _listProbe(
    name: 'walletTransactionsProvider',
    method: 'walletTransactions',
    state: (container) => container.read(walletTransactionsProvider),
    hold: (container) =>
        container.listen(walletTransactionsProvider, (_, __) {}),
  ),
  _mapProbe(
    name: 'customerFavoritesProvider',
    method: 'favorites',
    state: (container) => container.read(customerFavoritesProvider),
    hold: (container) => container.listen(customerFavoritesProvider, (_, __) {}),
  ),
  _listProbe(
    name: 'customerReviewsProvider',
    method: 'reviews',
    state: (container) => container.read(customerReviewsProvider),
    hold: (container) => container.listen(customerReviewsProvider, (_, __) {}),
  ),
  _listProbe(
    name: 'customerComplaintsProvider',
    method: 'complaints',
    state: (container) => container.read(customerComplaintsProvider),
    hold: (container) =>
        container.listen(customerComplaintsProvider, (_, __) {}),
  ),
  _listProbe(
    name: 'customerConversationsProvider',
    method: 'conversations',
    state: (container) => container.read(customerConversationsProvider),
    hold: (container) =>
        container.listen(customerConversationsProvider, (_, __) {}),
  ),
  _listProbe(
    name: 'customerNotificationsProvider',
    method: 'notifications',
    state: (container) => container.read(customerNotificationsProvider),
    hold: (container) =>
        container.listen(customerNotificationsProvider, (_, __) {}),
  ),
  _Probe(
    name: 'unreadNotificationsProvider',
    method: 'unreadNotificationsCount',
    repositoryValue: _unreadFor,
    expected: _unreadFor,
    emptyValue: 0,
    isEmpty: (value) => value == 0,
    state: (container) => container.read(unreadNotificationsProvider),
    hold: (container) =>
        container.listen(unreadNotificationsProvider, (_, __) {}),
  ),
  _listProbe(
    name: 'customerCouponsProvider',
    method: 'coupons',
    state: (container) => container.read(customerCouponsProvider),
    hold: (container) => container.listen(customerCouponsProvider, (_, __) {}),
  ),
];

void main() {
  for (final probe in _probes()) {
    group('${probe.name} is account scoped', () {
      test('account B never sees account A data, even while loading', () async {
        final repository = _FakeCustomerRepository();
        final container = _newContainer(repository);
        repository.setValue('u-a', probe.method, probe.arg, probe.repositoryValue('A'));

        _switchTo(container, repository, _accountA1);
        probe.hold(container);
        await _flush();
        expect(probe.state(container).valueOrNull, equals(probe.expected('A')));

        final gateB = repository.gate('u-b', probe.method, probe.arg);
        _switchTo(container, repository, _accountB1);
        await _flush();

        final loadingB = probe.state(container);
        expect(loadingB.isLoading, isTrue);
        expect(loadingB.hasValue, isFalse);
        expect(loadingB.valueOrNull, isNull);

        gateB.complete(probe.repositoryValue('B'));
        await _flush();
        expect(probe.state(container).valueOrNull, equals(probe.expected('B')));
        expect(repository.requests, [
          probe.requestKey('u-a'),
          probe.requestKey('u-b'),
        ]);
      });

      test('a late response from the previous account is ignored', () async {
        final repository = _FakeCustomerRepository();
        final container = _newContainer(repository);
        final gateA = repository.gate('u-a', probe.method, probe.arg);

        _switchTo(container, repository, _accountA1);
        probe.hold(container);
        await _flush();
        expect(probe.state(container).isLoading, isTrue);

        repository.setValue('u-b', probe.method, probe.arg, probe.repositoryValue('B'));
        _switchTo(container, repository, _accountB1);
        await _flush();
        expect(probe.state(container).valueOrNull, equals(probe.expected('B')));

        // A's answer lands after B is already on screen.
        gateA.complete(probe.repositoryValue('A'));
        await _flush();
        expect(probe.state(container).valueOrNull, equals(probe.expected('B')));
        expect(repository.requests, [
          probe.requestKey('u-a'),
          probe.requestKey('u-b'),
        ]);
      });

      test('same-user re-login rejects the old session response', () async {
        final repository = _FakeCustomerRepository();
        final container = _newContainer(repository);
        final gateOld = repository.gate('u-a', probe.method, probe.arg);
        final gateNew = repository.gate('u-a', probe.method, probe.arg);

        _switchTo(container, repository, _accountA1);
        probe.hold(container);
        await _flush();

        _switchTo(container, repository, _accountA2);
        await _flush();

        gateNew.complete(probe.repositoryValue('A-new'));
        await _flush();
        expect(
          probe.state(container).valueOrNull,
          equals(probe.expected('A-new')),
        );

        gateOld.complete(probe.repositoryValue('A-old'));
        await _flush();
        expect(
          probe.state(container).valueOrNull,
          equals(probe.expected('A-new')),
        );
        expect(repository.requests, hasLength(2));
      });

      test('logout clears the data and ignores the outstanding response', () async {
        final repository = _FakeCustomerRepository();
        final container = _newContainer(repository);
        final gateA = repository.gate('u-a', probe.method, probe.arg);

        _switchTo(container, repository, _accountA1);
        probe.hold(container);
        await _flush();
        expect(probe.state(container).isLoading, isTrue);

        _switchTo(container, repository, _signedOut);
        await _flush();
        expect(
          probe.isEmpty(probe.state(container).valueOrNull),
          isTrue,
          reason: 'signed out must expose an empty value',
        );

        gateA.complete(probe.repositoryValue('A'));
        await _flush();
        expect(probe.isEmpty(probe.state(container).valueOrNull), isTrue);
        // No customer request is issued while signed out.
        expect(repository.requests, [probe.requestKey('u-a')]);
      });

      test('failure for B does not fall back to A data', () async {
        final repository = _FakeCustomerRepository();
        final container = _newContainer(repository);
        repository.setValue('u-a', probe.method, probe.arg, probe.repositoryValue('A'));

        _switchTo(container, repository, _accountA1);
        probe.hold(container);
        await _flush();
        expect(probe.state(container).valueOrNull, equals(probe.expected('A')));

        repository.failWith(
          'u-b',
          probe.method,
          probe.arg,
          const ApiException(NetworkFailure()),
        );
        _switchTo(container, repository, _accountB1);
        await _flush();

        final failedB = probe.state(container);
        expect(failedB.hasError, isTrue);
        expect(failedB.hasValue, isFalse);
        expect(failedB.valueOrNull, isNull);
      });

      test('signed out holds no data and makes no request', () async {
        final repository = _FakeCustomerRepository();
        final container = _newContainer(repository);

        probe.hold(container);
        await _flush();

        expect(probe.state(container).valueOrNull, equals(probe.emptyValue));
        expect(repository.requests, isEmpty);
      });
    });
  }

  group('refresh guards', () {
    test('an older in-session response cannot replace a newer one', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);
      final first = repository.gate('u-a', 'wallet', null);
      final second = repository.gate('u-a', 'wallet', null);

      _switchTo(container, repository, _accountA1);
      container.listen(customerWalletProvider, (_, __) {});
      await _flush();
      expect(container.read(customerWalletProvider).isLoading, isTrue);

      // A manual reload starts a second request before the first one answers.
      container.invalidate(customerWalletProvider);
      await _flush();

      second.complete(<String, dynamic>{'marker': 'newer'});
      await _flush();
      expect(
        container.read(customerWalletProvider).valueOrNull,
        {'marker': 'newer'},
      );

      first.complete(<String, dynamic>{'marker': 'older'});
      await _flush();
      expect(
        container.read(customerWalletProvider).valueOrNull,
        {'marker': 'newer'},
      );
      expect(repository.requests, ['u-a|wallet|', 'u-a|wallet|']);
    });

    test('refresh with an ended expected session leaves B untouched', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);
      repository.setValue('u-a', 'wallet', null, <String, dynamic>{'marker': 'A'});
      repository.setValue('u-b', 'wallet', null, <String, dynamic>{'marker': 'B'});

      _switchTo(container, repository, _accountA1);
      container.listen(customerWalletProvider, (_, __) {});
      await _flush();

      _switchTo(container, repository, _accountB1);
      await _flush();
      expect(
        container.read(customerWalletProvider).valueOrNull,
        {'marker': 'B'},
      );

      final result = await container
          .read(customerWalletProvider.notifier)
          .refresh(expectedSession: _accountA1);

      expect(result, isNull);
      expect(
        container.read(customerWalletProvider).valueOrNull,
        {'marker': 'B'},
      );
      // The stale refresh must not issue a request under B's token.
      expect(repository.requests, ['u-a|wallet|', 'u-b|wallet|']);
    });

    test('refresh for the current session updates the data', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);
      repository.setValue('u-a', 'wallet', null, <String, dynamic>{'marker': 'A'});

      _switchTo(container, repository, _accountA1);
      container.listen(customerWalletProvider, (_, __) {});
      await _flush();

      repository.setValue(
        'u-a',
        'wallet',
        null,
        <String, dynamic>{'marker': 'A-refreshed'},
      );
      final result = await container
          .read(customerWalletProvider.notifier)
          .refresh(expectedSession: _accountA1);

      expect(result, {'marker': 'A-refreshed'});
      expect(
        container.read(customerWalletProvider).valueOrNull,
        {'marker': 'A-refreshed'},
      );
    });
  });

  group('write operations', () {
    testWidgets('a review submitted as A does not confirm under B', (
      tester,
    ) async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);
      _switchTo(container, repository, _accountA1);
      final gate = Completer<Map<String, dynamic>>();
      repository.reviewGate = gate;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: WriteReviewScreen(id: 'bk-1')),
        ),
      );

      await tester.tap(find.byIcon(Icons.star_outline).first);
      await tester.pump();
      await tester.tap(find.text('نشر التقييم'));
      await tester.pump();

      // Account switches while A's review is still on the wire.
      _switchTo(container, repository, _accountB1);
      await tester.pump();

      gate.complete({'id': 'review-1'});
      await tester.pump();
      await tester.pump();

      // No success confirmation and no navigation for B.
      expect(find.text('شكراً لك — تم نشر تقييمك'), findsNothing);
      expect(find.byType(WriteReviewScreen), findsOneWidget);
      expect(repository.reviewRequests, ['u-a|storeReview|bk-1']);
      // Nothing is re-sent under B's session.
      expect(repository.reviewRequests, hasLength(1));
    });

    testWidgets('mark-all-read from A does not reload B notifications', (
      tester,
    ) async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);
      repository.setValue('u-a', 'notifications', null, <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 1,
          'type': 'booking',
          'read_at': null,
          'data': <String, dynamic>{'title': 'إشعار A'},
        },
      ]);
      repository.setValue('u-b', 'notifications', null, <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 2,
          'type': 'booking',
          'read_at': null,
          'data': <String, dynamic>{'title': 'إشعار B'},
        },
      ]);

      _switchTo(container, repository, _accountA1);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: NotificationsScreen()),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('إشعار A'), findsOneWidget);

      final gate = Completer<void>();
      repository.markReadGates['u-a|markNotificationRead|1'] = [gate];

      await tester.tap(find.byIcon(Icons.mark_email_read_outlined));
      await tester.pump();
      expect(repository.markReadRequests, ['u-a|markNotificationRead|1']);

      // The session ends while A's mark-read is still running.
      _switchTo(container, repository, _accountB1);
      await tester.pump();
      await tester.pump();

      gate.complete();
      await tester.pump();
      await tester.pump();

      expect(repository.markReadRequests, ['u-a|markNotificationRead|1']);
      // A's confirmation must not invalidate (and reload) B's list.
      expect(repository.requests, ['u-a|notifications|', 'u-b|notifications|']);
      expect(find.text('إشعار B'), findsOneWidget);
      expect(find.text('إشعار A'), findsNothing);
    });

    testWidgets('a single mark-read from A does not reload B notifications', (
      tester,
    ) async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);
      repository.setValue('u-a', 'notifications', null, <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 1,
          'type': 'booking',
          'read_at': null,
          'data': <String, dynamic>{'title': 'إشعار A'},
        },
      ]);
      repository.setValue('u-b', 'notifications', null, <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 2,
          'type': 'booking',
          'read_at': null,
          'data': <String, dynamic>{'title': 'إشعار B'},
        },
      ]);

      _switchTo(container, repository, _accountA1);
      await tester.pumpWidget(
        _screen(container, const NotificationsScreen()),
      );
      await _pumpFrames(tester);

      final gate = Completer<void>();
      repository.markReadGates['u-a|markNotificationRead|1'] = [gate];

      await tester.tap(find.text('إشعار A'));
      await tester.pump();
      expect(repository.markReadRequests, ['u-a|markNotificationRead|1']);

      _switchTo(container, repository, _accountB1);
      await _pumpFrames(tester);
      gate.complete();
      await _pumpFrames(tester, 4);

      expect(repository.markReadRequests, ['u-a|markNotificationRead|1']);
      expect(repository.requests, ['u-a|notifications|', 'u-b|notifications|']);
      expect(find.text('إشعار B'), findsOneWidget);
      expect(find.text('إشعار A'), findsNothing);
    });
  });

  group('customerConversationProvider is session scoped', () {
    test('account B never sees A conversation, even while loading', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);
      final gateA = repository.gate('u-a', 'conversation', 'c1');
      final gateB = repository.gate('u-b', 'conversation', 'c1');

      _switchTo(container, repository, _accountA1);
      container.listen(customerConversationProvider('c1'), (_, __) {});
      await _flush();
      expect(
        container.read(customerConversationProvider('c1')).isLoading,
        isTrue,
      );

      _switchTo(container, repository, _accountB1);
      await _flush();
      final loadingB = container.read(customerConversationProvider('c1'));
      expect(loadingB.isLoading, isTrue);
      expect(loadingB.hasValue, isFalse);
      expect(loadingB.valueOrNull, isNull);

      gateB.complete(<String, dynamic>{'marker': 'B'});
      await _flush();
      expect(
        container.read(customerConversationProvider('c1')).valueOrNull,
        {'marker': 'B'},
      );

      gateA.complete(<String, dynamic>{'marker': 'A'});
      await _flush();
      expect(
        container.read(customerConversationProvider('c1')).valueOrNull,
        {'marker': 'B'},
      );
      expect(repository.requests, [
        'u-a|conversation|c1',
        'u-b|conversation|c1',
      ]);
    });

    test('same-user re-login rejects the old conversation response', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);
      final gateOld = repository.gate('u-a', 'conversation', 'c1');
      final gateNew = repository.gate('u-a', 'conversation', 'c1');

      _switchTo(container, repository, _accountA1);
      container.listen(customerConversationProvider('c1'), (_, __) {});
      await _flush();

      _switchTo(container, repository, _accountA2);
      await _flush();
      gateNew.complete(<String, dynamic>{'marker': 'A-new'});
      await _flush();
      expect(
        container.read(customerConversationProvider('c1')).valueOrNull,
        {'marker': 'A-new'},
      );

      gateOld.complete(<String, dynamic>{'marker': 'A-old'});
      await _flush();
      expect(
        container.read(customerConversationProvider('c1')).valueOrNull,
        {'marker': 'A-new'},
      );
      expect(repository.requests, hasLength(2));
    });

    test('ending the session mid-request clears the thread and ignores it', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);
      final gateA = repository.gate('u-a', 'conversation', 'c1');

      _switchTo(container, repository, _accountA1);
      container.listen(customerConversationProvider('c1'), (_, __) {});
      await _flush();
      expect(
        container.read(customerConversationProvider('c1')).isLoading,
        isTrue,
      );

      _switchTo(container, repository, _signedOut);
      await _flush();
      final signedOut = container.read(customerConversationProvider('c1'));
      expect(signedOut.valueOrNull, isEmpty);
      expect(signedOut.hasError, isFalse);

      // The old response lands after the session ended: it must be discarded.
      gateA.complete(<String, dynamic>{'marker': 'A'});
      await _flush();
      final afterwards = container.read(customerConversationProvider('c1'));
      expect(afterwards.valueOrNull, isEmpty);
      expect(afterwards.hasError, isFalse);
      expect(repository.requests, ['u-a|conversation|c1']);
    });

    test('failure for B does not fall back to A conversation', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);
      repository.setValue('u-a', 'conversation', 'c1', <String, dynamic>{
        'marker': 'A',
      });

      _switchTo(container, repository, _accountA1);
      container.listen(customerConversationProvider('c1'), (_, __) {});
      await _flush();
      expect(
        container.read(customerConversationProvider('c1')).valueOrNull,
        {'marker': 'A'},
      );

      repository.failWith(
        'u-b',
        'conversation',
        'c1',
        const ApiException(NetworkFailure()),
      );
      _switchTo(container, repository, _accountB1);
      await _flush();

      final failedB = container.read(customerConversationProvider('c1'));
      expect(failedB.hasError, isTrue);
      expect(failedB.error, isA<ApiException>());
      // Riverpod keeps the previous value attached to an AsyncError raised
      // after a dependency change. `unwrapPrevious` strips it: the error must
      // not carry A's conversation as usable data for B. ChatScreen's `.when`
      // renders the error branch, which the widget tests also verify.
      expect(failedB.unwrapPrevious().hasValue, isFalse);
      expect(failedB.unwrapPrevious().valueOrNull, isNull);
      expect(repository.requests, ['u-a|conversation|c1', 'u-b|conversation|c1']);
    });

    test('signed out holds no conversation and makes no request', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);

      container.listen(customerConversationProvider('c1'), (_, __) {});
      await _flush();

      expect(
        container.read(customerConversationProvider('c1')).valueOrNull,
        isEmpty,
      );
      expect(repository.requests, isEmpty);
    });
  });

  group('booking details writes', () {
    testWidgets('cancel from A does not reload B booking data', (tester) async {
      final repository = _FakeCustomerRepository();
      final container = await _pumpBookingDetails(
        tester,
        repository,
        status: 'pending',
      );
      container.listen(customerBookingsProvider(null), (_, __) {});
      final gate = repository.writeGate('u-a', 'cancelBooking', 'bk-1');

      await tester.tap(find.text('إلغاء الحجز'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'سبب الإلغاء');
      await tester.tap(find.text('تأكيد الإلغاء'));
      await tester.pump();
      await _waitForWrite(tester, repository, 'cancelBooking');

      _switchTo(container, repository, _accountB1);
      await _pumpFrames(tester);
      gate.complete(null);
      await _pumpFrames(tester, 4);

      expect(find.byType(BookingDetailsScreen), findsOneWidget);
      expect(find.text('تعذر إلغاء الحجز'), findsNothing);
      expect(_readCount(repository, 'u-b|booking|bk-1'), 1);
      expect(_readCount(repository, 'u-b|bookings|'), 1);
      expect(
        repository.writeRequests.where((key) => key.contains('cancelBooking')),
        hasLength(1),
      );
    });

    testWidgets('reschedule from A does not confirm or reload under B', (
      tester,
    ) async {
      final repository = _FakeCustomerRepository();
      final container = await _pumpBookingDetails(
        tester,
        repository,
        status: 'pending',
      );
      container.listen(customerBookingsProvider(null), (_, __) {});
      final gate = repository.writeGate('u-a', 'rescheduleBooking', 'bk-1');

      await tester.tap(find.text('تعديل الموعد'));
      await tester.pump();
      await tester.tap(find.text('تأكيد الموعد الجديد'));
      await tester.pump();
      await _waitForWrite(tester, repository, 'rescheduleBooking');

      _switchTo(container, repository, _accountB1);
      await _pumpFrames(tester);
      gate.complete(<String, dynamic>{});
      await _pumpFrames(tester, 4);

      expect(find.text('تم تعديل الموعد ✓'), findsNothing);
      expect(find.byType(BookingDetailsScreen), findsOneWidget);
      expect(_readCount(repository, 'u-b|booking|bk-1'), 1);
      expect(_readCount(repository, 'u-b|bookings|'), 1);
      expect(
        repository.writeRequests.where(
          (key) => key.contains('rescheduleBooking'),
        ),
        hasLength(1),
      );
    });

    testWidgets('rebook from A does not navigate or reload under B', (
      tester,
    ) async {
      final repository = _FakeCustomerRepository();
      final container = await _pumpBookingDetails(
        tester,
        repository,
        status: 'completed',
      );
      container.listen(customerBookingsProvider(null), (_, __) {});
      final gate = repository.writeGate('u-a', 'rebook', 'bk-1');

      await tester.tap(find.text('إعادة الحجز'));
      await tester.pump();
      await _waitForWrite(tester, repository, 'rebook');

      _switchTo(container, repository, _accountB1);
      await _pumpFrames(tester);
      gate.complete(<String, dynamic>{'id': 'bk-new'});
      await _pumpFrames(tester, 4);

      expect(find.byType(BookingDetailsScreen), findsOneWidget);
      expect(_readCount(repository, 'u-b|bookings|'), 1);
      expect(
        repository.writeRequests.where((key) => key.contains('rebook')),
        hasLength(1),
      );
    });

    testWidgets('pay from A does not confirm or reload B data', (tester) async {
      final repository = _FakeCustomerRepository();
      repository.setValue('u-a', 'payments', null, const <Map<String, dynamic>>[]);
      repository.setValue('u-b', 'payments', null, const <Map<String, dynamic>>[]);
      repository.setValue(
        'u-a',
        'walletTransactions',
        null,
        const <Map<String, dynamic>>[],
      );
      repository.setValue(
        'u-b',
        'walletTransactions',
        null,
        const <Map<String, dynamic>>[],
      );
      final container = await _pumpBookingDetails(
        tester,
        repository,
        status: 'pending',
      );
      container.listen(customerPaymentsProvider, (_, __) {});
      container.listen(walletTransactionsProvider, (_, __) {});
      final gate = repository.writeGate('u-a', 'payBooking', 'bk-1');

      await tester.tap(find.text('الدفع الآن'));
      await tester.pump();
      await tester.tap(find.textContaining('محفظة المنصة'));
      await tester.pump();
      await _waitForWrite(tester, repository, 'payBooking');

      _switchTo(container, repository, _accountB1);
      await _pumpFrames(tester);
      gate.complete(<String, dynamic>{});
      await _pumpFrames(tester, 4);

      expect(find.text('تم الدفع بنجاح ✓'), findsNothing);
      expect(find.byType(BookingDetailsScreen), findsOneWidget);
      expect(_readCount(repository, 'u-b|booking|bk-1'), 1);
      expect(_readCount(repository, 'u-b|payments|'), 1);
      expect(_readCount(repository, 'u-b|walletTransactions|'), 1);
      expect(
        repository.writeRequests.where((key) => key.contains('payBooking')),
        hasLength(1),
      );
    });
  });

  group('booking wizard write isolation', () {
    testWidgets('create from A does not pay, navigate or reload under B', (
      tester,
    ) async {
      _useTallViewport(tester);
      final repository = _FakeCustomerRepository();
      repository.setValue('u-a', 'addresses', null, <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'addr-a',
          'label': 'منزل A',
          'full_address': 'عنوان A',
          'is_default': true,
        },
      ]);
      repository.setValue('u-b', 'addresses', null, <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'addr-b',
          'label': 'منزل B',
          'full_address': 'عنوان B',
          'is_default': true,
        },
      ]);
      repository.setValue('u-a', 'wallet', null, <String, dynamic>{
        'balance': 500,
      });
      repository.setValue('u-b', 'wallet', null, <String, dynamic>{
        'balance': 300,
      });
      repository.setValue('u-a', 'bookings', null, const <Map<String, dynamic>>[]);
      repository.setValue('u-b', 'bookings', null, const <Map<String, dynamic>>[]);

      final container = _newContainer(repository);
      _switchTo(container, repository, _accountA1);
      container.listen(customerBookingsProvider(null), (_, __) {});
      final gate = repository.writeGate('u-a', 'createBooking');

      await tester.pumpWidget(
        _screen(
          container,
          const BookingWizardScreen(
            initialService: Service(
              id: 'svc-1',
              slug: 'cleaning',
              titleAr: 'تنظيف',
              titleEn: 'Cleaning',
              basePrice: 100,
              currencyCode: 'SAR',
              categoryId: 'cat-1',
            ),
          ),
        ),
      );
      await _pumpFrames(tester);

      await tester.tap(find.text('التالي'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      for (var i = 0; i < 40 && find.text('عنوان A').evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(find.text('عنوان A'), findsOneWidget);

      await tester.tap(find.text('التالي'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      for (var i = 0; i < 60 && find.text('9:00 ص').evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      expect(find.text('9:00 ص'), findsOneWidget);

      await tester.tap(find.text('9:00 ص'));
      await tester.pump();
      await tester.tap(find.text('التالي'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.textContaining('تأكيد الحجز'));
      await tester.pump();
      await _waitForWrite(tester, repository, 'createBooking');

      _switchTo(container, repository, _accountB1);
      await _pumpFrames(tester);
      gate.complete(<String, dynamic>{'id': 'bk-new'});
      await _pumpFrames(tester, 4);

      expect(find.byType(BookingWizardScreen), findsOneWidget);
      expect(
        repository.writeRequests.where((key) => key.contains('payBooking')),
        isEmpty,
      );
      expect(
        repository.writeRequests.where((key) => key.contains('createBooking')),
        hasLength(1),
      );
      expect(_readCount(repository, 'u-b|bookings|'), 1);
    });
  });

  group('wallet write isolation', () {
    testWidgets('top-up created as A never opens a pending dialog for B', (
      tester,
    ) async {
      _useTallViewport(tester);
      final repository = _FakeCustomerRepository();
      _seedWallet(repository);
      final container = _newContainer(repository);
      _switchTo(container, repository, _accountA1);
      final gate = repository.writeGate('u-a', 'addFunds');

      await tester.pumpWidget(_screen(container, const WalletScreen()));
      await _pumpFrames(tester);
      expect(find.text('شحن الرصيد'), findsOneWidget);

      await tester.tap(find.text('شحن الرصيد'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.enterText(find.byType(TextField).last, '100');
      await tester.tap(find.text('تأكيد الشحن'));
      await tester.pump();
      await _waitForWrite(tester, repository, 'addFunds');

      _switchTo(container, repository, _accountB1);
      await _pumpFrames(tester);
      gate.complete(<String, dynamic>{'payment_id': 'pay-1', 'amount': 100});
      await _pumpFrames(tester, 4);

      expect(find.text('بانتظار إتمام الدفع'), findsNothing);
      expect(
        repository.writeRequests.where(
          (key) => key.contains('confirmWalletPayment'),
        ),
        isEmpty,
      );
      expect(_readCount(repository, 'u-b|wallet|'), 1);
      expect(_readCount(repository, 'u-b|walletTransactions|'), 1);
    });

    testWidgets('confirming A top-up does not credit or reload under B', (
      tester,
    ) async {
      _useTallViewport(tester);
      final repository = _FakeCustomerRepository();
      _seedWallet(repository);
      // The server returns a payment intent for the top-up; without it the
      // screen has nothing to confirm.
      repository.setValue('u-a', 'addFunds', null, <String, dynamic>{
        'payment_id': 'pay-1',
        'amount': 100,
      });
      final container = _newContainer(repository);
      _switchTo(container, repository, _accountA1);
      final gate = repository.writeGate(
        'u-a',
        'confirmWalletPayment',
        'pay-1',
      );

      await tester.pumpWidget(_screen(container, const WalletScreen()));
      await _pumpFrames(tester);

      await tester.tap(find.text('شحن الرصيد'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.enterText(find.byType(TextField).last, '100');
      await tester.tap(find.text('تأكيد الشحن'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('بانتظار إتمام الدفع'), findsOneWidget);
      repository.setValue(
        'u-a',
        'wallet',
        null,
        <String, dynamic>{'balance': 500},
      );

      await tester.tap(find.text('تم الدفع — تأكيد'));
      await tester.pump();
      await _waitForWrite(tester, repository, 'confirmWalletPayment');

      _switchTo(container, repository, _accountB1);
      await _pumpFrames(tester);
      gate.complete(null);
      await _pumpFrames(tester, 4);

      expect(find.text('تم شحن المحفظة بنجاح ✓'), findsNothing);
      expect(_readCount(repository, 'u-b|wallet|'), 1);
      expect(_readCount(repository, 'u-b|walletTransactions|'), 1);
      expect(
        repository.writeRequests.where(
          (key) => key.contains('confirmWalletPayment'),
        ),
        hasLength(1),
      );
    });
  });

  group('address write isolation', () {
    testWidgets('creating an address as A does not close B form or reload B', (
      tester,
    ) async {
      _useTallViewport(tester);
      final repository = _FakeCustomerRepository();
      _seedAddresses(repository);
      final container = _newContainer(repository);
      _switchTo(container, repository, _accountA1);
      final gate = repository.writeGate('u-a', 'storeAddress');

      await tester.pumpWidget(_screen(container, const AddressBookScreen()));
      await _pumpFrames(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.enterText(find.byType(TextField).at(1), 'شارع الاختبار');
      await tester.tap(find.text('حفظ العنوان'));
      await tester.pump();
      await _waitForWrite(tester, repository, 'storeAddress');

      _switchTo(container, repository, _accountB1);
      await _pumpFrames(tester);
      gate.complete(<String, dynamic>{'id': 'addr-new'});
      await _pumpFrames(tester, 4);

      expect(find.text('عنوان جديد'), findsOneWidget);
      expect(_readCount(repository, 'u-b|addresses|'), 1);
      expect(
        repository.writeRequests.where((key) => key.contains('storeAddress')),
        hasLength(1),
      );
    });

    testWidgets('updating an address as A does not reload B addresses', (
      tester,
    ) async {
      _useTallViewport(tester);
      final repository = _FakeCustomerRepository();
      _seedAddresses(repository);
      final container = _newContainer(repository);
      _switchTo(container, repository, _accountA1);
      final gate = repository.writeGate('u-a', 'updateAddress', 'addr-a');

      await tester.pumpWidget(_screen(container, const AddressBookScreen()));
      await _pumpFrames(tester);

      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.tap(find.text('حفظ التعديلات'));
      await tester.pump();
      await _waitForWrite(tester, repository, 'updateAddress');

      _switchTo(container, repository, _accountB1);
      await _pumpFrames(tester);
      gate.complete(<String, dynamic>{});
      await _pumpFrames(tester, 4);

      expect(find.text('تعديل العنوان'), findsOneWidget);
      expect(_readCount(repository, 'u-b|addresses|'), 1);
      expect(
        repository.writeRequests.where(
          (key) => key.contains('updateAddress'),
        ),
        hasLength(1),
      );
    });

    testWidgets('deleting an address as A does not reload B addresses', (
      tester,
    ) async {
      _useTallViewport(tester);
      final repository = _FakeCustomerRepository();
      _seedAddresses(repository);
      final container = _newContainer(repository);
      _switchTo(container, repository, _accountA1);
      final gate = repository.writeGate('u-a', 'destroyAddress', 'addr-a');

      await tester.pumpWidget(_screen(container, const AddressBookScreen()));
      await _pumpFrames(tester);

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pump();
      await _waitForWrite(tester, repository, 'destroyAddress');

      _switchTo(container, repository, _accountB1);
      await _pumpFrames(tester);
      gate.complete(null);
      await _pumpFrames(tester, 4);

      expect(find.byType(AddressBookScreen), findsOneWidget);
      expect(_readCount(repository, 'u-b|addresses|'), 1);
      expect(
        repository.writeRequests.where(
          (key) => key.contains('destroyAddress'),
        ),
        hasLength(1),
      );
    });
  });

  group('complaint write isolation', () {
    testWidgets('complaint from A does not confirm or reload B complaints', (
      tester,
    ) async {
      final repository = _FakeCustomerRepository();
      repository.setValue(
        'u-a',
        'complaints',
        null,
        const <Map<String, dynamic>>[],
      );
      repository.setValue(
        'u-b',
        'complaints',
        null,
        const <Map<String, dynamic>>[],
      );
      final container = _newContainer(repository);
      _switchTo(container, repository, _accountA1);
      container.listen(customerComplaintsProvider, (_, __) {});
      final gate = repository.writeGate('u-a', 'storeComplaint');

      await tester.pumpWidget(
        _screen(container, const SubmitComplaintScreen()),
      );
      await _pumpFrames(tester);

      await tester.tap(find.text('جودة منخفضة'));
      await tester.enterText(find.byType(TextField), 'تفاصيل الشكوى');
      await tester.pump();
      await tester.tap(find.text('إرسال البلاغ'));
      await tester.pump();
      await _waitForWrite(tester, repository, 'storeComplaint');

      _switchTo(container, repository, _accountB1);
      await _pumpFrames(tester);
      gate.complete(<String, dynamic>{'id': 'cmp-1'});
      await _pumpFrames(tester, 4);

      expect(find.text('تم إرسال البلاغ — سيتواصل معك الدعم'), findsNothing);
      expect(find.byType(SubmitComplaintScreen), findsOneWidget);
      expect(_readCount(repository, 'u-b|complaints|'), 1);
      expect(
        repository.writeRequests.where(
          (key) => key.contains('storeComplaint'),
        ),
        hasLength(1),
      );
    });
  });

  group('settings write isolation', () {
    testWidgets('password change from A does not confirm under B', (
      tester,
    ) async {
      _useTallViewport(tester);
      _ignoreListTileInkWarning();
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);
      _switchTo(container, repository, _accountA1);
      final gate = repository.writeGate('u-a', 'changePassword');

      await tester.pumpWidget(_screen(container, const SettingsScreen()));
      await _pumpFrames(tester);

      await tester.tap(find.text('تغيير كلمة المرور'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'oldpass1');
      await tester.enterText(fields.at(1), 'newpass12');
      await tester.enterText(fields.at(2), 'newpass12');
      await tester.tap(find.text('حفظ'));
      await tester.pump();
      await _waitForWrite(tester, repository, 'changePassword');

      _switchTo(container, repository, _accountB1);
      await _pumpFrames(tester);
      gate.complete(null);
      await _pumpFrames(tester, 4);

      expect(find.text('تم تغيير كلمة المرور بنجاح'), findsNothing);
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(
        repository.writeRequests.where(
          (key) => key.contains('changePassword'),
        ),
        hasLength(1),
      );
    });

    testWidgets('account deletion from A does not log out B', (tester) async {
      _useTallViewport(tester);
      _ignoreListTileInkWarning();
      final repository = _FakeCustomerRepository();
      final container = _newContainer(
        repository,
        extra: [
          authNotifierProvider.overrideWith(
            (ref) => _CountingAuthNotifier(ref),
          ),
        ],
      );
      _switchTo(container, repository, _accountA1);
      final auth = container.read(authNotifierProvider.notifier)
          as _CountingAuthNotifier;
      final gate = repository.writeGate('u-a', 'destroyAccount');

      await tester.pumpWidget(_screen(container, const SettingsScreen()));
      await _pumpFrames(tester);

      await tester.tap(find.text('حذف الحساب'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.enterText(find.byType(TextField), 'secret123');
      await tester.tap(find.text('حذف نهائي'));
      await tester.pump();
      await _waitForWrite(tester, repository, 'destroyAccount');

      _switchTo(container, repository, _accountB1);
      await _pumpFrames(tester);
      gate.complete(null);
      await _pumpFrames(tester, 4);

      expect(auth.logoutCalls, 0);
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('تعذر حذف الحساب — تحقق من كلمة المرور'), findsNothing);
      expect(
        repository.writeRequests.where(
          (key) => key.contains('destroyAccount'),
        ),
        hasLength(1),
      );
    });
  });
}

Future<ProviderContainer> _pumpBookingDetails(
  WidgetTester tester,
  _FakeCustomerRepository repository, {
  required String status,
}) async {
  _useTallViewport(tester);
  repository.setValue(
    'u-a',
    'booking',
    'bk-1',
    _bookingPayload('A', status: status),
  );
  repository.setValue(
    'u-b',
    'booking',
    'bk-1',
    _bookingPayload('B', status: status),
  );
  repository.setValue('u-a', 'bookings', null, const <Map<String, dynamic>>[]);
  repository.setValue('u-b', 'bookings', null, const <Map<String, dynamic>>[]);

  final container = _newContainer(repository);
  _switchTo(container, repository, _accountA1);
  await tester.pumpWidget(
    _screen(container, const BookingDetailsScreen(id: 'bk-1')),
  );
  await _pumpFrames(tester);
  return container;
}

void _seedWallet(_FakeCustomerRepository repository) {
  for (final account in ['u-a', 'u-b']) {
    repository.setValue(account, 'wallet', null, <String, dynamic>{
      'balance': account == 'u-a' ? 500 : 300,
      'currency': 'SAR',
    });
    repository.setValue(
      account,
      'walletTransactions',
      null,
      const <Map<String, dynamic>>[],
    );
  }
}

void _seedAddresses(_FakeCustomerRepository repository) {
  repository.setValue('u-a', 'addresses', null, <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 'addr-a',
      'label': 'منزل A',
      'full_address': 'عنوان A',
      'address': 'عنوان A',
      'phone': '0500000000',
      'is_default': true,
    },
  ]);
  repository.setValue('u-b', 'addresses', null, <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 'addr-b',
      'label': 'منزل B',
      'full_address': 'عنوان B',
      'address': 'عنوان B',
      'phone': '0500000001',
      'is_default': true,
    },
  ]);
}
