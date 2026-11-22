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
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/favorite_toggle_button.dart';

ApiClient _dummyClient() => ApiClient(
  dio: Dio(),
  baseUrl: 'http://localhost/api',
  appVersion: '1.0.0+0',
  storage: SecureStorage(),
);

/// Fake repository that mirrors the real toggle contract: it mutates the
/// favorite bucket and returns the server-confirmed boolean.
class _FakeCustomerRepository extends CustomerRepository {
  _FakeCustomerRepository(this.favoriteKeys, {this.nestedFavorites = false})
    : super(CustomerRemoteSource(_dummyClient()));

  final Set<String> favoriteKeys;

  /// Mimics the real backend shape
  /// `{services: {data: [...]}, providers: {data: [...]}}`.
  final bool nestedFavorites;
  final Map<String, Completer<void>> gates = {};
  final List<String> calls = [];
  Object? error;

  /// Holds the first favorites list load open, or makes it fail, so tests can
  /// reproduce the "unknown state" window exactly.
  Completer<void>? favoritesGate;
  Object? favoritesError;
  int favoritesCalls = 0;

  Future<bool> _toggle(String key) async {
    calls.add(key);
    final gate = gates[key];
    if (gate != null) await gate.future;
    final failure = error;
    if (failure != null) throw failure;
    if (favoriteKeys.contains(key)) {
      favoriteKeys.remove(key);
      return false;
    }
    favoriteKeys.add(key);
    return true;
  }

  @override
  Future<bool> toggleServiceFavorite(String serviceId) =>
      _toggle('service:$serviceId');

  @override
  Future<bool> toggleProviderFavorite(String providerId) =>
      _toggle('provider:$providerId');

  /// The shared list mirrors [favoriteKeys], like the real endpoint does.
  @override
  Future<Map<String, dynamic>> favorites() async {
    favoritesCalls++;
    final gate = favoritesGate;
    if (gate != null) await gate.future;
    final failure = favoritesError;
    if (failure != null) throw failure;
    return _favoritesData(this);
  }
}

Map<String, dynamic> _favoritesData(_FakeCustomerRepository repository) {
  List<Map<String, dynamic>> bucket(String prefix) => [
    for (final key in repository.favoriteKeys)
      if (key.startsWith(prefix)) {'id': key.substring(prefix.length)},
  ];
  if (repository.nestedFavorites) {
    return {
      'services': {'data': bucket('service:')},
      'providers': {'data': bucket('provider:')},
    };
  }
  return {'services': bucket('service:'), 'providers': bucket('provider:')};
}

Widget _wrap(_FakeCustomerRepository repository, Widget child) => ProviderScope(
  overrides: [
    customerRepositoryProvider.overrideWithValue(repository),
    // A fixed signed-in session: the account-scoped favorites provider and
    // the toggle controller both derive their keys from it.
    sessionScopeProvider.overrideWithValue(
      const SessionScope(isAuthenticated: true, userId: 'u-1', generation: 1),
    ),
  ],
  child: MaterialApp(home: Scaffold(body: child)),
);

Future<void> _pump(
  WidgetTester tester,
  _FakeCustomerRepository repository,
  Widget child,
) async {
  await tester.pumpWidget(_wrap(repository, child));
  await tester.pumpAndSettle();
}

/// Builds without settling, so a gated favorites load stays in progress.
Future<void> _pumpRaw(
  WidgetTester tester,
  _FakeCustomerRepository repository,
  Widget child,
) async {
  await tester.pumpWidget(_wrap(repository, child));
  await tester.pump();
}

Future<void> _tapButton(WidgetTester tester, [Finder? finder]) async {
  await tester.tap(finder ?? find.byType(IconButton));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('rapid taps on the same service send one toggle', (tester) async {
    final repository = _FakeCustomerRepository({});
    final gate = Completer<void>();
    repository.gates['service:s1'] = gate;

    await _pump(
      tester,
      repository,
      const Center(child: FavoriteToggleButton(id: 's1')),
    );

    await _tapButton(tester);
    await _tapButton(tester);
    await _tapButton(tester);
    await tester.pump();

    expect(repository.calls, ['service:s1']);

    gate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('the same item on two screens cannot toggle twice', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository({});
    final gate = Completer<void>();
    repository.gates['service:s1'] = gate;

    await tester.pumpWidget(
      _wrap(
        repository,
        Center(
          child: Builder(
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FavoriteToggleButton(key: Key('first-heart'), id: 's1'),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const Scaffold(
                        body: Center(
                          child: FavoriteToggleButton(
                            key: Key('second-heart'),
                            id: 's1',
                          ),
                        ),
                      ),
                    ),
                  ),
                  child: const Text('فتح الشاشة الثانية'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tapButton(tester);
    await tester.pump();
    await tester.tap(find.text('فتح الشاشة الثانية'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // The second screen mirrors the shared in-flight state.
    final secondHeart = find.byKey(const Key('second-heart'));
    expect(
      find.descendant(
        of: secondHeart,
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    final secondButton = find.descendant(
      of: secondHeart,
      matching: find.byType(IconButton),
    );
    expect(tester.widget<IconButton>(secondButton).onPressed, isNull);

    await tester.tap(secondButton);
    await tester.pump();
    expect(repository.calls, ['service:s1']);

    gate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('provider favorites use the same in-flight protection', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository({});
    final gate = Completer<void>();
    repository.gates['provider:p1'] = gate;

    await _pump(
      tester,
      repository,
      const Center(child: FavoriteToggleButton(id: 'p1', isProvider: true)),
    );

    await _tapButton(tester);
    await _tapButton(tester);
    await tester.pump();

    expect(repository.calls, ['provider:p1']);

    gate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('different items can toggle concurrently', (tester) async {
    final repository = _FakeCustomerRepository({});
    final serviceGate = Completer<void>();
    final providerGate = Completer<void>();
    repository.gates['service:s1'] = serviceGate;
    repository.gates['provider:p1'] = providerGate;

    await _pump(
      tester,
      repository,
      const Column(
        children: [
          FavoriteToggleButton(id: 's1'),
          FavoriteToggleButton(id: 'p1', isProvider: true),
        ],
      ),
    );

    final buttons = find.byType(FavoriteToggleButton);
    await _tapButton(
      tester,
      find.descendant(of: buttons.at(0), matching: find.byType(IconButton)),
    );
    await _tapButton(
      tester,
      find.descendant(of: buttons.at(1), matching: find.byType(IconButton)),
    );
    await tester.pump();

    expect(
      repository.calls,
      containsAll(<String>['service:s1', 'provider:p1']),
    );

    serviceGate.complete();
    providerGate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('shows a spinner and disables the button while in flight', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository({});
    final gate = Completer<void>();
    repository.gates['service:s1'] = gate;

    await _pump(
      tester,
      repository,
      const Center(child: FavoriteToggleButton(id: 's1')),
    );

    await _tapButton(tester);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNull,
    );

    gate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('returns to its normal state after the request completes', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository({});

    await _pump(
      tester,
      repository,
      const Center(child: FavoriteToggleButton(id: 's1')),
    );

    await _tapButton(tester);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNotNull,
    );
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('icon follows the favorited value returned by the server', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository({});

    await _pump(
      tester,
      repository,
      const Center(child: FavoriteToggleButton(id: 's1')),
    );

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await _tapButton(tester);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);

    await _tapButton(tester);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);
    expect(repository.calls, ['service:s1', 'service:s1']);
  });

  testWidgets('releases the lock after a successful toggle', (tester) async {
    final repository = _FakeCustomerRepository({});

    await _pump(
      tester,
      repository,
      const Center(child: FavoriteToggleButton(id: 's1')),
    );

    await _tapButton(tester);
    await tester.pumpAndSettle();
    await _tapButton(tester);
    await tester.pumpAndSettle();

    expect(repository.calls, ['service:s1', 'service:s1']);
  });

  testWidgets('failure keeps the previous state and shows the API message', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository({'service:s1'});
    repository.error = const ApiException(NetworkFailure());

    await _pump(
      tester,
      repository,
      const Center(child: FavoriteToggleButton(id: 's1')),
    );

    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await _tapButton(tester);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
    expect(find.text('تعذر الاتصال بالخادم. تحقق من الشبكة.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('releases the lock after a failure so a retry can succeed', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository({});
    repository.error = const ApiException(NetworkFailure());

    await _pump(
      tester,
      repository,
      const Center(child: FavoriteToggleButton(id: 's1')),
    );

    await _tapButton(tester);
    await tester.pumpAndSettle();
    expect(repository.calls, ['service:s1']);

    repository.error = null;
    await _tapButton(tester);
    await tester.pumpAndSettle();

    expect(repository.calls, ['service:s1', 'service:s1']);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('a loading list disables the heart and sends no toggle', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository({});
    final gate = Completer<void>();
    repository.favoritesGate = gate;

    await _pumpRaw(
      tester,
      repository,
      const Center(child: FavoriteToggleButton(id: 's1')),
    );

    expect(find.byTooltip('جارٍ تحميل المفضلة'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNull,
    );

    await _tapButton(tester);
    await tester.pump();

    expect(repository.calls, isEmpty);
    expect(repository.favoritesCalls, 1);

    gate.complete();
    await tester.pumpAndSettle();

    // Once the confirmed list arrives the button becomes interactive.
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNotNull,
    );
    expect(find.byTooltip('إضافة إلى المفضلة'), findsOneWidget);
  });

  testWidgets('a failed list load disables the heart and sends no toggle', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository({});
    repository.favoritesError = const ApiException(NetworkFailure());

    await _pump(
      tester,
      repository,
      const Center(child: FavoriteToggleButton(id: 's1')),
    );

    expect(find.byTooltip('تعذر تحميل المفضلة'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNull,
    );

    await _tapButton(tester);
    await tester.pump();

    expect(repository.calls, isEmpty);
  });

  testWidgets('a retried list load re-enables the button', (tester) async {
    final repository = _FakeCustomerRepository({'service:s1'});
    repository.favoritesError = const ApiException(NetworkFailure());

    await tester.pumpWidget(
      _wrap(
        repository,
        Consumer(
          builder: (context, ref, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FavoriteToggleButton(id: 's1'),
              TextButton(
                onPressed: () =>
                    ref.invalidate(customerFavoritesProvider),
                child: const Text('retry'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNull,
    );

    repository.favoritesError = null;
    await tester.tap(find.text('retry'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNotNull,
    );
    // The loaded list contains s1, so the heart reflects it.
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await _tapButton(tester);
    await tester.pumpAndSettle();

    expect(repository.calls, ['service:s1']);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  testWidgets('displayed state follows the loaded list per item', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository({
      'service:s1',
      'provider:p1',
    });

    await _pump(
      tester,
      repository,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FavoriteToggleButton(key: Key('svc'), id: 's1'),
          FavoriteToggleButton(key: Key('svc-other'), id: 's2'),
          FavoriteToggleButton(
            key: Key('prov'),
            id: 'p1',
            isProvider: true,
          ),
        ],
      ),
    );

    Finder iconOf(String key) =>
        find.descendant(of: find.byKey(Key(key)), matching: find.byType(Icon));

    expect(
      tester.widget<Icon>(iconOf('svc')).icon,
      Icons.favorite,
    );
    expect(
      tester.widget<Icon>(iconOf('svc-other')).icon,
      Icons.favorite_border,
    );
    expect(
      tester.widget<Icon>(iconOf('prov')).icon,
      Icons.favorite,
    );
  });

  testWidgets('the real nested favorites envelope drives every heart', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository({
      'service:s1',
      'provider:p1',
    }, nestedFavorites: true);

    await _pump(
      tester,
      repository,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FavoriteToggleButton(key: Key('svc'), id: 's1'),
          FavoriteToggleButton(key: Key('svc-other'), id: 's2'),
          FavoriteToggleButton(
            key: Key('prov'),
            id: 'p1',
            isProvider: true,
          ),
        ],
      ),
    );

    Finder iconOf(String key) =>
        find.descendant(of: find.byKey(Key(key)), matching: find.byType(Icon));

    expect(tester.widget<Icon>(iconOf('svc')).icon, Icons.favorite);
    expect(tester.widget<Icon>(iconOf('svc-other')).icon, Icons.favorite_border);
    expect(tester.widget<Icon>(iconOf('prov')).icon, Icons.favorite);

    for (final key in ['svc', 'svc-other', 'prov']) {
      expect(
        tester
            .widget<IconButton>(
              find.descendant(
                of: find.byKey(Key(key)),
                matching: find.byType(IconButton),
              ),
            )
            .onPressed,
        isNotNull,
      );
    }
  });

  testWidgets('while one item is pending the other item stays interactive', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository({});
    final gate = Completer<void>();
    repository.gates['service:s1'] = gate;

    await _pump(
      tester,
      repository,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FavoriteToggleButton(key: Key('svc'), id: 's1'),
          FavoriteToggleButton(
            key: Key('prov'),
            id: 'p1',
            isProvider: true,
          ),
        ],
      ),
    );

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('svc')),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pump();

    final first = tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(const Key('svc')),
        matching: find.byType(IconButton),
      ),
    );
    final second = tester.widget<IconButton>(
      find.descendant(
        of: find.byKey(const Key('prov')),
        matching: find.byType(IconButton),
      ),
    );
    expect(first.onPressed, isNull);
    expect(second.onPressed, isNotNull);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('prov')),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pump();

    expect(repository.calls, ['service:s1', 'provider:p1']);

    gate.complete();
    await tester.pumpAndSettle();
  });
}
