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
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/providers/favorite_toggle_provider.dart';
import 'package:saber_flutter/shared/widgets/favorite_toggle_button.dart';

ApiClient _dummyClient() => ApiClient(
  dio: Dio(),
  baseUrl: 'http://localhost/api',
  appVersion: '1.0.0+0',
  storage: SecureStorage(),
);

Map<String, dynamic> _empty() => const <String, dynamic>{
  'services': <dynamic>[],
  'providers': <dynamic>[],
};

/// Repository whose favorites list and toggle answers can be gated and
/// failed per account, so refresh sources can be replayed deterministically.
class _FakeCustomerRepository extends CustomerRepository {
  _FakeCustomerRepository() : super(CustomerRemoteSource(_dummyClient()));

  String account = 'u-a';
  final Map<String, Map<String, dynamic>> data = {
    'u-a': _empty(),
    'u-b': _empty(),
  };

  /// Optional queued list responses, consumed before [data].
  final List<Map<String, dynamic>> responses = [];
  final List<Completer<void>> favoriteGates = [];
  Object? nextFavoritesError;
  final List<String> favoriteCalls = [];

  final Map<String, bool> toggleResults = {};
  final Map<String, Object> toggleErrors = {};
  final Map<String, Completer<bool>> toggleGates = {};
  final List<String> toggleCalls = [];

  @override
  Future<Map<String, dynamic>> favorites() async {
    final accountAtCall = account;
    favoriteCalls.add(accountAtCall);
    if (favoriteGates.isNotEmpty) {
      await favoriteGates.removeAt(0).future;
    }
    final failure = nextFavoritesError;
    nextFavoritesError = null;
    if (failure != null) throw failure;
    if (responses.isNotEmpty) return responses.removeAt(0);
    return data[accountAtCall] ?? _empty();
  }

  @override
  Future<bool> toggleServiceFavorite(String serviceId) =>
      _toggle('service', serviceId);

  @override
  Future<bool> toggleProviderFavorite(String providerId) =>
      _toggle('provider', providerId);

  Future<bool> _toggle(String type, String id) async {
    final accountAtCall = account;
    final key = '$accountAtCall|$type:$id';
    toggleCalls.add(key);

    final gate = toggleGates[key];
    if (gate != null) await gate.future;
    final error = toggleErrors.remove(key);
    if (error != null) throw error;

    final result = toggleResults[key] ?? true;
    // Mirror the change into the server-side list so the follow-up refresh
    // observes what the real API would return.
    final list = data[accountAtCall] ?? _empty();
    final services = [...dataList(list['services'])];
    final providers = [...dataList(list['providers'])];
    final bucket = type == 'service' ? services : providers;
    bucket.removeWhere((item) => str(item['id']) == id);
    if (result) bucket.add(<String, dynamic>{'id': id});
    data[accountAtCall] = {
      'services': services,
      'providers': providers,
    };
    return result;
  }
}

const _accountA1 = SessionScope(
  isAuthenticated: true,
  userId: 'u-a',
  generation: 1,
);
const _accountA2 = SessionScope(
  isAuthenticated: true,
  userId: 'u-a',
  generation: 3,
);
const _accountB1 = SessionScope(
  isAuthenticated: true,
  userId: 'u-b',
  generation: 2,
);
const _signedOut = SessionScope(isAuthenticated: false, generation: 0);

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

void _hold(ProviderContainer container) {
  container.listen(customerFavoritesProvider, (_, __) {});
  container.listen(favoriteToggleControllerProvider, (_, __) {});
}

List<String> _ids(ProviderContainer container, {bool providers = false}) {
  final data = container.read(customerFavoritesProvider).valueOrNull;
  return [
    for (final item
        in dataList(data?[providers ? 'providers' : 'services'] ?? const []))
      str(item['id']),
  ];
}

String _serviceKey() =>
    FavoriteToggleController.confirmedKeyFor(
      _accountA1,
      isProvider: false,
      id: 's1',
    );

String _providerKey() =>
    FavoriteToggleController.confirmedKeyFor(
      _accountA1,
      isProvider: true,
      id: 'p1',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeCustomerRepository repository;
  late ProviderContainer container;

  Future<void> ready([SessionScope scope = _accountA1]) async {
    repository = _FakeCustomerRepository();
    container = _newContainer(repository);
    _switchTo(container, repository, scope);
    _hold(container);
    await pumpEventQueue();
  }

  test('successful toggle + successful refresh drops the confirmation', () async {
    await ready();

    final result = await container
        .read(favoriteToggleControllerProvider.notifier)
        .toggle(isProvider: false, id: 's1');

    expect(result, isTrue);
    expect(_ids(container), ['s1']);
    expect(container.read(favoriteToggleControllerProvider).confirmed, isEmpty);
  });

  test('failed follow-up refresh keeps the confirmation safely', () async {
    await ready();
    repository.nextFavoritesError = const ApiException(NetworkFailure());

    final result = await container
        .read(favoriteToggleControllerProvider.notifier)
        .toggle(isProvider: false, id: 's1');

    expect(result, isTrue);
    // The list stayed at its last successful value.
    expect(_ids(container), isEmpty);
    expect(
      container.read(favoriteToggleControllerProvider).confirmed[_serviceKey()],
      isTrue,
    );
    expect(container.read(favoriteToggleControllerProvider).pending, isEmpty);
  });

  test('external refresh after a failed toggle refresh wins over confirmed', () async {
    await ready();
    repository.nextFavoritesError = const ApiException(NetworkFailure());
    final notifier = container.read(favoriteToggleControllerProvider.notifier);
    await notifier.toggle(isProvider: false, id: 's1');
    expect(
      container.read(favoriteToggleControllerProvider).confirmed[_serviceKey()],
      isTrue,
    );

    // A later pull-to-refresh returns a different server list (s1 absent).
    repository.data['u-a'] = {
      'services': <dynamic>[],
      'providers': <dynamic>[],
    };
    final refreshed = await container
        .read(customerFavoritesProvider.notifier)
        .refresh();

    expect(refreshed, isNotNull);
    expect(container.read(favoriteToggleControllerProvider).confirmed, isEmpty);
    expect(_ids(container), isEmpty);
  });

  test('external refresh with another item clears the stale confirmation', () async {
    await ready();
    repository.nextFavoritesError = const ApiException(NetworkFailure());
    final notifier = container.read(favoriteToggleControllerProvider.notifier);
    await notifier.toggle(isProvider: true, id: 'p1');
    expect(
      container
          .read(favoriteToggleControllerProvider)
          .confirmed[_providerKey()],
      isTrue,
    );

    repository.data['u-a'] = {
      'services': <dynamic>[],
      'providers': <dynamic>[
        {'id': 'p1', 'business_name': 'مزود'},
      ],
    };
    await container.read(customerFavoritesProvider.notifier).refresh();

    final state = container.read(favoriteToggleControllerProvider);
    expect(state.confirmed, isEmpty);
    expect(_ids(container, providers: true), ['p1']);
  });

  test('a normal toggle never clears the confirmation before the list catches up', () async {
    await ready();
    final gate = Completer<void>();
    repository.favoriteGates.add(gate);

    var confirmedDuring = false;
    var clearedWhileListMissing = false;
    container.listen(favoriteToggleControllerProvider, (previous, next) {
      if (next.confirmed[_serviceKey()] == true) confirmedDuring = true;
      final was = previous?.confirmed.containsKey(_serviceKey()) ?? false;
      final still = next.confirmed.containsKey(_serviceKey());
      if (was && !still && !_ids(container).contains('s1')) {
        clearedWhileListMissing = true;
      }
    });

    final future = container
        .read(favoriteToggleControllerProvider.notifier)
        .toggle(isProvider: false, id: 's1');
    await pumpEventQueue();

    expect(confirmedDuring, isTrue);
    expect(_ids(container), isEmpty);
    expect(container.read(favoriteToggleControllerProvider).pending, hasLength(1));

    gate.complete();
    await future;

    expect(clearedWhileListMissing, isFalse);
    expect(_ids(container), ['s1']);
    expect(container.read(favoriteToggleControllerProvider).confirmed, isEmpty);
  });

  test('an old account refresh completing later never changes the new session', () async {
    await ready();
    final gate = Completer<void>();
    repository.favoriteGates.add(gate);
    repository.data['u-a'] = {
      'services': <dynamic>[
        {'id': 's-a'},
      ],
      'providers': <dynamic>[],
    };

    final oldRefresh = container
        .read(customerFavoritesProvider.notifier)
        .refresh();
    await pumpEventQueue();

    repository.data['u-b'] = {
      'services': <dynamic>[],
      'providers': <dynamic>[
        {'id': 'p-b', 'business_name': 'مزود ب'},
      ],
    };
    _switchTo(container, repository, _accountB1);
    await pumpEventQueue();

    gate.complete();
    await oldRefresh;
    await pumpEventQueue();

    expect(_ids(container, providers: true), ['p-b']);
    expect(container.read(customerFavoritesProvider).valueOrNull, isNotNull);
    expect(container.read(favoriteToggleControllerProvider).confirmed, isEmpty);
  });

  test('A -> logout -> B never exposes A confirmed values to B', () async {
    await ready();
    repository.nextFavoritesError = const ApiException(NetworkFailure());
    await container
        .read(favoriteToggleControllerProvider.notifier)
        .toggle(isProvider: false, id: 's1');
    expect(
      container.read(favoriteToggleControllerProvider).confirmed[_serviceKey()],
      isTrue,
    );

    _switchTo(container, repository, _signedOut);
    await pumpEventQueue();
    expect(container.read(favoriteToggleControllerProvider).confirmed, isEmpty);

    repository.data['u-b'] = {
      'services': <dynamic>[
        {'id': 's-b'},
      ],
      'providers': <dynamic>[],
    };
    _switchTo(container, repository, _accountB1);
    await pumpEventQueue();

    expect(container.read(favoriteToggleControllerProvider).confirmed, isEmpty);
    expect(_ids(container), ['s-b']);
  });

  test('same account re-login with a new generation does not inherit confirmed', () async {
    await ready();
    repository.nextFavoritesError = const ApiException(NetworkFailure());
    await container
        .read(favoriteToggleControllerProvider.notifier)
        .toggle(isProvider: false, id: 's1');
    expect(
      container.read(favoriteToggleControllerProvider).confirmed[_serviceKey()],
      isTrue,
    );

    repository.data['u-a'] = _empty();
    _switchTo(container, repository, _accountA2);
    await pumpEventQueue();

    expect(container.read(favoriteToggleControllerProvider).confirmed, isEmpty);
    expect(_ids(container), isEmpty);
  });

  test('concurrent toggles on different items stay independent', () async {
    await ready();
    final serviceGate = Completer<bool>();
    final providerGate = Completer<bool>();
    repository.toggleGates['u-a|service:s1'] = serviceGate;
    repository.toggleGates['u-a|provider:p1'] = providerGate;

    final notifier = container.read(favoriteToggleControllerProvider.notifier);
    final serviceFuture = notifier.toggle(isProvider: false, id: 's1');
    final providerFuture = notifier.toggle(isProvider: true, id: 'p1');
    await pumpEventQueue();

    expect(
      container.read(favoriteToggleControllerProvider).pending,
      hasLength(2),
    );

    serviceGate.complete(true);
    providerGate.complete(true);
    await Future.wait([serviceFuture, providerFuture]);
    await pumpEventQueue();

    expect(
      repository.toggleCalls,
      containsAll(<String>['u-a|service:s1', 'u-a|provider:p1']),
    );
    expect(_ids(container), ['s1']);
    expect(_ids(container, providers: true), ['p1']);
    expect(container.read(favoriteToggleControllerProvider).pending, isEmpty);
  });

  testWidgets('the heart follows the newest list after an external refresh', (
    tester,
  ) async {
    repository = _FakeCustomerRepository();
    container = _newContainer(repository);
    _switchTo(container, repository, _accountA1);
    _hold(container);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: FavoriteToggleButton(id: 's1'))),
        ),
      ),
    );
    // Flush the initial favorites load microtask.
    await tester.pump();
    await tester.pump();

    repository.nextFavoritesError = const ApiException(NetworkFailure());
    await container
        .read(favoriteToggleControllerProvider.notifier)
        .toggle(isProvider: false, id: 's1');
    await tester.pump();

    // The failed list refresh left the confirmed toggle visible.
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    repository.data['u-a'] = {
      'services': <dynamic>[],
      'providers': <dynamic>[],
    };
    await container.read(customerFavoritesProvider.notifier).refresh();
    await tester.pump();

    // The newer successful list no longer contains s1, so the heart clears.
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);
  });
}
