import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber_flutter/core/errors/failures.dart';
import 'package:saber_flutter/core/network/api_client.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/core/storage/secure_storage.dart';
import 'package:saber_flutter/data/repositories/customer_repository.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';
import 'package:saber_flutter/modules/customer/screens/favorites_screen.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/providers/favorite_toggle_provider.dart';

ApiClient _dummyClient() => ApiClient(
  dio: Dio(),
  baseUrl: 'http://localhost/api',
  appVersion: '1.0.0+0',
  storage: SecureStorage(),
);

/// Repository whose answers are driven per account and can be held open, so
/// tests can replay out-of-order responses exactly.
class _FakeCustomerRepository extends CustomerRepository {
  _FakeCustomerRepository() : super(CustomerRemoteSource(_dummyClient()));

  String account = 'signed-out';

  final Map<String, List<Completer<Map<String, dynamic>>>> favoriteGates = {};
  final Map<String, List<Completer<List<Map<String, dynamic>>>>>
  conversationGates = {};
  final Map<String, List<Completer<Map<String, dynamic>>>>
  conversationDetailGates = {};
  final Map<String, Map<String, dynamic>> favoriteData = {};
  final Map<String, List<Map<String, dynamic>>> conversationData = {};
  final Map<String, Map<String, dynamic>> conversationDetailData = {};
  final Map<String, Object> favoriteErrors = {};
  final Map<String, Object> conversationErrors = {};
  final List<String> favoriteRequests = [];
  final List<String> conversationRequests = [];
  final List<String> conversationDetailRequests = [];

  final Map<String, List<Completer<bool>>> toggleGates = {};
  final Map<String, Object> toggleErrors = {};
  final Map<String, bool> toggleResults = {};
  final List<String> toggleRequests = [];

  void gateFavorites(String account, Completer<Map<String, dynamic>> gate) =>
      favoriteGates.putIfAbsent(account, () => []).add(gate);

  void gateConversations(
    String account,
    Completer<List<Map<String, dynamic>>> gate,
  ) => conversationGates.putIfAbsent(account, () => []).add(gate);

  void gateToggle(String key, Completer<bool> gate) =>
      toggleGates.putIfAbsent(key, () => []).add(gate);

  void gateConversationDetail(
    String account,
    String id,
    Completer<Map<String, dynamic>> gate,
  ) => conversationDetailGates
      .putIfAbsent('$account|$id', () => [])
      .add(gate);

  @override
  Future<Map<String, dynamic>> favorites() {
    favoriteRequests.add(account);
    final error = favoriteErrors[account];
    if (error != null) return Future.error(error);
    final queue = favoriteGates[account];
    if (queue != null && queue.isNotEmpty) return queue.removeAt(0).future;
    return Future.value(favoriteData[account] ?? const <String, dynamic>{});
  }

  @override
  Future<List<Map<String, dynamic>>> conversations() {
    conversationRequests.add(account);
    final error = conversationErrors[account];
    if (error != null) return Future.error(error);
    final queue = conversationGates[account];
    if (queue != null && queue.isNotEmpty) return queue.removeAt(0).future;
    return Future.value(
      conversationData[account] ?? const <Map<String, dynamic>>[],
    );
  }

  @override
  Future<Map<String, dynamic>> conversation(String id) {
    final key = '$account|$id';
    conversationDetailRequests.add(key);
    final queue = conversationDetailGates[key];
    if (queue != null && queue.isNotEmpty) return queue.removeAt(0).future;
    return Future.value(
      conversationDetailData[key] ?? const <String, dynamic>{},
    );
  }

  @override
  Future<bool> toggleServiceFavorite(String serviceId) =>
      _toggle('service', serviceId);

  @override
  Future<bool> toggleProviderFavorite(String providerId) =>
      _toggle('provider', providerId);

  Future<bool> _toggle(String type, String id) async {
    final key = '$account|$type:$id';
    toggleRequests.add(key);

    var result = toggleResults[key] ?? true;
    final gateQueue = toggleGates[key];
    if (gateQueue != null && gateQueue.isNotEmpty) {
      result = await gateQueue.removeAt(0).future;
    }
    final error = toggleErrors.remove(key);
    if (error != null) throw error;
    return result;
  }
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

ProviderContainer _newContainer(_FakeCustomerRepository repository) {
  final container = ProviderContainer(
    overrides: [
      customerRepositoryProvider.overrideWithValue(repository),
      sessionScopeProvider.overrideWith(
        (ref) => ref.watch(_testSessionProvider),
      ),
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
}

Map<String, dynamic> _favoritesFor(String providerName) => {
  'services': <dynamic>[],
  'providers': <dynamic>[
    {'id': 'p-$providerName', 'business_name': providerName},
  ],
};

List<Map<String, dynamic>> _conversationFor(String label) => [
  {
    'id': 'conv-$label',
    'subject': label,
    'participants': <dynamic>[],
  },
];

void _expectEmptyFavorites(Map<String, dynamic>? data) {
  expect(data, isNotNull);
  expect(data!['providers'] ?? const <dynamic>[], isEmpty);
  expect(data['services'] ?? const <dynamic>[], isEmpty);
}

void main() {
  group('customerFavoritesProvider is account scoped', () {
    test('account B never sees account A data, even while loading', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);
      final gateA = Completer<Map<String, dynamic>>();
      repository.gateFavorites('u-a', gateA);

      _switchTo(container, repository, _accountA1);
      container.listen(customerFavoritesProvider, (_, __) {});
      await _flush();
      expect(container.read(customerFavoritesProvider).isLoading, isTrue);

      gateA.complete(_favoritesFor('مزود A'));
      await _flush();
      expect(
        container.read(customerFavoritesProvider).valueOrNull,
        _favoritesFor('مزود A'),
      );

      final gateB = Completer<Map<String, dynamic>>();
      repository.gateFavorites('u-b', gateB);
      _switchTo(container, repository, _accountB1);
      await _flush();

      final loadingB = container.read(customerFavoritesProvider);
      expect(loadingB.isLoading, isTrue);
      // A previous value must not survive into the new account's loading
      // state: the UI would paint it as B's favorites.
      expect(loadingB.hasValue, isFalse);
      expect(loadingB.valueOrNull, isNull);

      gateB.complete(_favoritesFor('مزود B'));
      await _flush();
      expect(
        container.read(customerFavoritesProvider).valueOrNull,
        _favoritesFor('مزود B'),
      );
      expect(repository.favoriteRequests, ['u-a', 'u-b']);
    });

    test('a late response from the previous account is ignored', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);

      final gateA = Completer<Map<String, dynamic>>();
      repository.gateFavorites('u-a', gateA);
      _switchTo(container, repository, _accountA1);
      container.listen(customerFavoritesProvider, (_, __) {});
      await _flush();

      repository.favoriteData['u-b'] = _favoritesFor('مزود B');
      _switchTo(container, repository, _accountB1);
      await _flush();
      expect(
        container.read(customerFavoritesProvider).valueOrNull,
        _favoritesFor('مزود B'),
      );

      // A's server response arrives *after* B is already shown.
      gateA.complete(_favoritesFor('مزود A'));
      await _flush();
      expect(
        container.read(customerFavoritesProvider).valueOrNull,
        _favoritesFor('مزود B'),
      );
    });

    test('same-user re-login rejects the old session response', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);

      final gateA1 = Completer<Map<String, dynamic>>();
      final gateA2 = Completer<Map<String, dynamic>>();
      repository.gateFavorites('u-a', gateA1);
      repository.gateFavorites('u-a', gateA2);

      _switchTo(container, repository, _accountA1);
      container.listen(customerFavoritesProvider, (_, __) {});
      await _flush();

      // Same user, new login session (generation changed).
      _switchTo(container, repository, _accountA2);
      await _flush();

      gateA2.complete(_favoritesFor('نسخة A الجديدة'));
      await _flush();
      expect(
        container.read(customerFavoritesProvider).valueOrNull,
        _favoritesFor('نسخة A الجديدة'),
      );

      gateA1.complete(_favoritesFor('نسخة A القديمة'));
      await _flush();
      expect(
        container.read(customerFavoritesProvider).valueOrNull,
        _favoritesFor('نسخة A الجديدة'),
      );
    });

    test('logout clears data and ignores the outstanding response', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);

      final gateA = Completer<Map<String, dynamic>>();
      repository.gateFavorites('u-a', gateA);
      _switchTo(container, repository, _accountA1);
      container.listen(customerFavoritesProvider, (_, __) {});
      await _flush();

      final scope = container.read(customerFavoritesProvider);
      expect(scope.isLoading, isTrue);

      _switchTo(container, repository, _signedOut);
      await _flush();
      _expectEmptyFavorites(
        container.read(customerFavoritesProvider).valueOrNull,
      );

      gateA.complete(_favoritesFor('مزود A'));
      await _flush();
      _expectEmptyFavorites(
        container.read(customerFavoritesProvider).valueOrNull,
      );
      // No new request was issued while signed out.
      expect(repository.favoriteRequests, ['u-a']);
    });

    test('failure for B does not fall back to A data', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);

      repository.favoriteData['u-a'] = _favoritesFor('مزود A');
      _switchTo(container, repository, _accountA1);
      container.listen(customerFavoritesProvider, (_, __) {});
      await _flush();
      expect(
        container.read(customerFavoritesProvider).valueOrNull,
        _favoritesFor('مزود A'),
      );

      repository.favoriteErrors['u-b'] = const ApiException(NetworkFailure());
      _switchTo(container, repository, _accountB1);
      await _flush();

      final failedB = container.read(customerFavoritesProvider);
      expect(failedB.hasError, isTrue);
      expect(failedB.hasValue, isFalse);
      expect(failedB.valueOrNull, isNull);
    });

    test('signed-out state holds no data and makes no request', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);

      container.listen(customerFavoritesProvider, (_, __) {});
      await _flush();

      _expectEmptyFavorites(
        container.read(customerFavoritesProvider).valueOrNull,
      );
      expect(repository.favoriteRequests, isEmpty);
    });
  });

  group('customerConversationsProvider is account scoped', () {
    test('account B never sees A conversations, even while loading', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);

      repository.conversationData['u-a'] = _conversationFor('محادثة A');
      _switchTo(container, repository, _accountA1);
      container.listen(customerConversationsProvider, (_, __) {});
      await _flush();
      expect(
        container.read(customerConversationsProvider).valueOrNull,
        _conversationFor('محادثة A'),
      );

      final gateB = Completer<List<Map<String, dynamic>>>();
      repository.gateConversations('u-b', gateB);
      _switchTo(container, repository, _accountB1);
      await _flush();

      final loadingB = container.read(customerConversationsProvider);
      expect(loadingB.isLoading, isTrue);
      expect(loadingB.hasValue, isFalse);
      expect(loadingB.valueOrNull, isNull);

      gateB.complete(_conversationFor('محادثة B'));
      await _flush();
      expect(
        container.read(customerConversationsProvider).valueOrNull,
        _conversationFor('محادثة B'),
      );
      expect(repository.conversationRequests, ['u-a', 'u-b']);
    });

    test('a late response from the previous account is ignored', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);

      final gateA = Completer<List<Map<String, dynamic>>>();
      repository.gateConversations('u-a', gateA);
      _switchTo(container, repository, _accountA1);
      container.listen(customerConversationsProvider, (_, __) {});
      await _flush();

      repository.conversationData['u-b'] = _conversationFor('محادثة B');
      _switchTo(container, repository, _accountB1);
      await _flush();
      expect(
        container.read(customerConversationsProvider).valueOrNull,
        _conversationFor('محادثة B'),
      );

      // A's old answer arrives late and must not replace B's conversation.
      gateA.complete(_conversationFor('محادثة A متأخرة'));
      await _flush();
      expect(
        container.read(customerConversationsProvider).valueOrNull,
        _conversationFor('محادثة B'),
      );
    });

    test('logout drops conversations and ignores the outstanding response', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);

      final gateA = Completer<List<Map<String, dynamic>>>();
      repository.gateConversations('u-a', gateA);
      _switchTo(container, repository, _accountA1);
      container.listen(customerConversationsProvider, (_, __) {});
      await _flush();

      _switchTo(container, repository, _signedOut);
      await _flush();
      expect(
        container.read(customerConversationsProvider).valueOrNull,
        isEmpty,
      );

      gateA.complete(_conversationFor('محادثة A متأخرة'));
      await _flush();
      expect(
        container.read(customerConversationsProvider).valueOrNull,
        isEmpty,
      );
      expect(repository.conversationRequests, ['u-a']);
    });

    test('same-user re-login rejects the old session response', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);

      final gateA1 = Completer<List<Map<String, dynamic>>>();
      final gateA2 = Completer<List<Map<String, dynamic>>>();
      repository.gateConversations('u-a', gateA1);
      repository.gateConversations('u-a', gateA2);

      _switchTo(container, repository, _accountA1);
      container.listen(customerConversationsProvider, (_, __) {});
      await _flush();

      _switchTo(container, repository, _accountA2);
      await _flush();

      gateA2.complete(_conversationFor('جلسة جديدة'));
      await _flush();
      gateA1.complete(_conversationFor('جلسة قديمة'));
      await _flush();

      expect(
        container.read(customerConversationsProvider).valueOrNull,
        _conversationFor('جلسة جديدة'),
      );
    });

    test('conversation detail rejects a response from an ended session', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);

      final gate = Completer<Map<String, dynamic>>();
      repository.gateConversationDetail('u-a', 'c1', gate);
      _switchTo(container, repository, _accountA1);

      final subscription = container.listen(
        customerConversationProvider('c1'),
        (_, __) {},
      );
      addTearDown(subscription.close);

      final stale = container.read(customerConversationProvider('c1').future);
      await _flush();

      repository.conversationDetailData['u-b|c1'] = {
        'id': 'c1',
        'subject': 'محادثة B',
      };
      _switchTo(container, repository, _accountB1);
      await _flush();
      expect(
        container.read(customerConversationProvider('c1')).valueOrNull,
        {'id': 'c1', 'subject': 'محادثة B'},
      );

      // A's thread arrives after B's session started. The provider's body
      // rejects it at result time (StaleSessionException), so B's thread —
      // not A's — remains on screen and no extra request is issued.
      gate.complete({'id': 'c1', 'subject': 'محادثة A'});
      await stale;
      await _flush();
      expect(
        container.read(customerConversationProvider('c1')).valueOrNull,
        {'id': 'c1', 'subject': 'محادثة B'},
      );
      expect(repository.conversationDetailRequests, ['u-a|c1', 'u-b|c1']);
    });

    test('failure for B does not fall back to A conversations', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);

      repository.conversationData['u-a'] = _conversationFor('محادثة A');
      _switchTo(container, repository, _accountA1);
      container.listen(customerConversationsProvider, (_, __) {});
      await _flush();

      repository.conversationErrors['u-b'] = const ApiException(
        NetworkFailure(),
      );
      _switchTo(container, repository, _accountB1);
      await _flush();

      final failedB = container.read(customerConversationsProvider);
      expect(failedB.hasError, isTrue);
      expect(failedB.hasValue, isFalse);
      expect(failedB.valueOrNull, isNull);
    });

    test('signed out holds no conversations and makes no request', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);

      container.listen(customerConversationsProvider, (_, __) {});
      await _flush();

      expect(
        container.read(customerConversationsProvider).valueOrNull,
        isEmpty,
      );
      expect(repository.conversationRequests, isEmpty);
    });
  });

  group('favorite toggle state is account scoped', () {
    test('confirmed value is dropped when the session changes', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);

      _switchTo(container, repository, _accountA1);
      container.listen(customerFavoritesProvider, (_, __) {});
      await _flush();
      container.read(favoriteToggleControllerProvider);
      await _flush();

      final keyA = FavoriteToggleController.confirmedKeyFor(
        _accountA1,
        isProvider: false,
        id: 's1',
      );
      final keyB = FavoriteToggleController.confirmedKeyFor(
        _accountB1,
        isProvider: false,
        id: 's1',
      );

      expect(
        await container
            .read(favoriteToggleControllerProvider.notifier)
            .toggle(isProvider: false, id: 's1'),
        isTrue,
      );
      expect(
        container.read(favoriteToggleControllerProvider).confirmedFor(keyA),
        isTrue,
      );

      _switchTo(container, repository, _accountB1);
      await _flush();

      final afterSwitch = container.read(favoriteToggleControllerProvider);
      expect(afterSwitch.confirmedFor(keyA), isNull);
      expect(afterSwitch.confirmedFor(keyB), isNull);
      expect(afterSwitch.confirmed, isEmpty);
    });

    test('a pending lock for A does not block B for the same item', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);
      _switchTo(container, repository, _accountA1);
      container.listen(customerFavoritesProvider, (_, __) {});
      container.read(favoriteToggleControllerProvider);
      await _flush();

      final gateA = Completer<bool>();
      repository.gateToggle('u-a|service:s1', gateA);
      final toggleA = container
          .read(favoriteToggleControllerProvider.notifier)
          .toggle(isProvider: false, id: 's1');
      await _flush();

      final pendingKeyA = FavoriteToggleController.pendingKeyFor(
        _accountA1,
        isProvider: false,
        id: 's1',
      );
      expect(
        container.read(favoriteToggleControllerProvider).isPending(pendingKeyA),
        isTrue,
      );

      _switchTo(container, repository, _accountB1);
      await _flush();

      // B is not blocked by A's still-running request.
      final resultB = await container
          .read(favoriteToggleControllerProvider.notifier)
          .toggle(isProvider: false, id: 's1');
      expect(resultB, isTrue);
      expect(repository.toggleRequests, [
        'u-a|service:s1',
        'u-b|service:s1',
      ]);

      final keyB = FavoriteToggleController.confirmedKeyFor(
        _accountB1,
        isProvider: false,
        id: 's1',
      );

      // A finishes later with the opposite value: B's confirmed state and the
      // shared list must stay untouched.
      final favoritesRequestsBefore = repository.favoriteRequests.length;
      gateA.complete(false);
      expect(await toggleA, isFalse);
      await _flush();

      expect(repository.favoriteRequests.length, favoritesRequestsBefore);
      expect(
        container.read(favoriteToggleControllerProvider).confirmedFor(keyB),
        isTrue,
      );
      expect(container.read(favoriteToggleControllerProvider).pending, isEmpty);
    });

    test('same account cannot toggle one item twice across re-login', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);
      _switchTo(container, repository, _accountA1);
      container.listen(customerFavoritesProvider, (_, __) {});
      container.read(favoriteToggleControllerProvider);
      await _flush();

      final gate = Completer<bool>();
      repository.gateToggle('u-a|service:s1', gate);
      final first = container
          .read(favoriteToggleControllerProvider.notifier)
          .toggle(isProvider: false, id: 's1');
      await _flush();

      // Same user logs in again while the first toggle is still running.
      _switchTo(container, repository, _accountA2);
      await _flush();

      final second = await container
          .read(favoriteToggleControllerProvider.notifier)
          .toggle(isProvider: false, id: 's1');
      expect(second, isNull);
      expect(repository.toggleRequests, ['u-a|service:s1']);

      gate.complete(true);
      await first;
      await _flush();
      expect(container.read(favoriteToggleControllerProvider).pending, isEmpty);

      // Once the first request settled, the account is free to toggle again.
      final third = await container
          .read(favoriteToggleControllerProvider.notifier)
          .toggle(isProvider: false, id: 's1');
      expect(third, isTrue);
      expect(repository.toggleRequests, [
        'u-a|service:s1',
        'u-a|service:s1',
      ]);
    });

    test('locks are released after success and after failure', () async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);
      _switchTo(container, repository, _accountA1);
      container.listen(customerFavoritesProvider, (_, __) {});
      container.read(favoriteToggleControllerProvider);
      await _flush();

      expect(
        await container
            .read(favoriteToggleControllerProvider.notifier)
            .toggle(isProvider: false, id: 's1'),
        isTrue,
      );
      expect(container.read(favoriteToggleControllerProvider).pending, isEmpty);

      repository.toggleErrors['u-a|service:s1'] = const ApiException(
        NetworkFailure(),
      );
      await expectLater(
        container
            .read(favoriteToggleControllerProvider.notifier)
            .toggle(isProvider: false, id: 's1'),
        throwsA(isA<ApiException>()),
      );
      expect(container.read(favoriteToggleControllerProvider).pending, isEmpty);
    });
  });

  group('favorites UI', () {
    testWidgets('rapid account switch never paints the previous account data', (
      tester,
    ) async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);

      final gateA = Completer<Map<String, dynamic>>();
      repository.gateFavorites('u-a', gateA);
      _switchTo(container, repository, _accountA1);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: FavoritesScreen()),
        ),
      );
      await tester.pump();
      expect(find.text('مزود A'), findsNothing);

      final gateB = Completer<Map<String, dynamic>>();
      repository.gateFavorites('u-b', gateB);
      _switchTo(container, repository, _accountB1);
      await tester.pump();

      // A's response arrives after the switch; the UI is still on B's load.
      gateA.complete(_favoritesFor('مزود A'));
      await tester.pump();
      expect(find.text('مزود A'), findsNothing);

      gateB.complete(_favoritesFor('مزود B'));
      await tester.pumpAndSettle();
      expect(find.text('مزود B'), findsOneWidget);
      expect(find.text('مزود A'), findsNothing);
    });

    testWidgets('logout shows the empty state, not the last account', (
      tester,
    ) async {
      final repository = _FakeCustomerRepository();
      final container = _newContainer(repository);
      repository.favoriteData['u-a'] = _favoritesFor('مزود A');
      _switchTo(container, repository, _accountA1);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: FavoritesScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('مزود A'), findsOneWidget);

      _switchTo(container, repository, _signedOut);
      await tester.pumpAndSettle();

      expect(find.text('مزود A'), findsNothing);
      expect(find.text('لا توجد عناصر مفضلة'), findsOneWidget);
    });
  });
}
