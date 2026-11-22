import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/core/errors/failures.dart';
import 'package:saber_flutter/core/network/api_client.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/core/storage/secure_storage.dart';
import 'package:saber_flutter/data/repositories/customer_repository.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';
import 'package:saber_flutter/modules/customer/screens/favorites_screen.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/favorite_toggle_provider.dart';
import 'package:saber_flutter/shared/widgets/favorite_toggle_button.dart';
import 'package:saber_flutter/shared/widgets/service_card.dart';

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

Map<String, dynamic> _service(String id) => {
  'id': id,
  'slug': 'slug-$id',
  'name': 'خدمة $id',
  'price': 100,
  'currency': 'SAR',
};

Map<String, dynamic> _provider(String id) => {
  'id': id,
  'business_name': 'مزود $id',
  'average_rating': '4.5',
};

/// Repository backed by a per-account favorites list. Toggling mutates only
/// the favorites membership; the catalog sets prove the item itself is never
/// deleted.
class _FakeCustomerRepository extends CustomerRepository {
  _FakeCustomerRepository() : super(CustomerRemoteSource(_dummyClient()));

  String account = 'u-a';
  final Map<String, Map<String, dynamic>> data = {
    'u-a': _empty(),
    'u-b': _empty(),
  };

  final Set<String> catalogServices = {'s1', 's2'};
  final Set<String> catalogProviders = {'p1', 'p2'};

  final List<String> toggleCalls = [];
  final Map<String, Completer<void>> toggleGates = {};
  Object? toggleError;

  Completer<void>? favoritesGate;
  Object? favoritesError;
  int favoritesCalls = 0;

  @override
  Future<Map<String, dynamic>> favorites() async {
    final accountAtCall = account;
    favoritesCalls++;
    final gate = favoritesGate;
    if (gate != null) await gate.future;
    final failure = favoritesError;
    if (failure != null) throw failure;
    return data[accountAtCall] ?? _empty();
  }

  Future<bool> _toggle(String type, String id) async {
    final accountAtCall = account;
    final key = '$type:$id';
    toggleCalls.add(key);
    final gate = toggleGates[accountAtCall];
    if (gate != null) await gate.future;
    final failure = toggleError;
    if (failure != null) throw failure;
    final list = data[accountAtCall] ?? _empty();
    final services = [...dataList(list['services'])];
    final providers = [...dataList(list['providers'])];
    final bucket = type == 'service' ? services : providers;
    final wasFavorite = bucket.any((item) => str(item['id']) == id);
    bucket.removeWhere((item) => str(item['id']) == id);
    if (!wasFavorite) {
      bucket.add(type == 'service' ? _service(id) : _provider(id));
    }
    data[accountAtCall] = {
      'services': services,
      'providers': providers,
    };
    return !wasFavorite;
  }

  @override
  Future<bool> toggleServiceFavorite(String serviceId) =>
      _toggle('service', serviceId);

  @override
  Future<bool> toggleProviderFavorite(String providerId) =>
      _toggle('provider', providerId);
}

const _accountA = SessionScope(
  isAuthenticated: true,
  userId: 'u-a',
  generation: 1,
);
const _accountB = SessionScope(
  isAuthenticated: true,
  userId: 'u-b',
  generation: 2,
);

final _testSessionProvider = StateProvider<SessionScope>((ref) => _accountA);

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

GoRouter _router() => GoRouter(
  initialLocation: '/favorites',
  routes: [
    GoRoute(path: '/favorites', builder: (_, __) => const FavoritesScreen()),
    GoRoute(
      path: '/home/services/:slug',
      builder: (context, __) => Scaffold(
        appBar: AppBar(title: const Text('service-details')),
        body: Center(
          child: Consumer(
            builder: (context, ref, _) => TextButton(
              onPressed: () async {
                await ref
                    .read(favoriteToggleControllerProvider.notifier)
                    .toggle(isProvider: false, id: 's2');
                if (context.mounted) context.pop();
              },
              child: const Text('add-s2'),
            ),
          ),
        ),
      ),
    ),
    GoRoute(
      path: '/home/providers/:id',
      builder: (_, state) => Scaffold(
        body: Center(
          child: Text('provider-details:${state.pathParameters['id']}'),
        ),
      ),
    ),
  ],
);

Widget _app(ProviderContainer container) => UncontrolledProviderScope(
  container: container,
  child: MaterialApp.router(
    routerConfig: _router(),
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
  ),
);

Future<void> _pump(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(_app(container));
  await tester.pumpAndSettle();
}

Finder _serviceHeart(int index) => find.descendant(
  of: find.byType(ServiceCard).at(index),
  matching: find.byType(FavoriteToggleButton),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a service can be removed from the favorites screen', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    repository.data['u-a'] = {
      'services': [_service('s1')],
      'providers': <dynamic>[],
    };
    final container = _newContainer(repository);
    await _pump(tester, container);

    expect(find.text('خدمة s1'), findsWidgets);

    await tester.tap(
      find.descendant(
        of: _serviceHeart(0),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('خدمة s1'), findsNothing);
    expect(find.text('لا توجد عناصر مفضلة'), findsOneWidget);
    expect(repository.toggleCalls, ['service:s1']);
  });

  testWidgets('a provider can be removed from the favorites screen', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    repository.data['u-a'] = {
      'services': <dynamic>[],
      'providers': [_provider('p1')],
    };
    final container = _newContainer(repository);
    await _pump(tester, container);

    expect(find.text('مزود p1'), findsOneWidget);
    final heart = find.byType(FavoriteToggleButton);
    expect(tester.widget<FavoriteToggleButton>(heart).id, 'p1');
    expect(tester.widget<FavoriteToggleButton>(heart).isProvider, isTrue);

    await tester.tap(
      find.descendant(of: heart, matching: find.byType(IconButton)),
    );
    await tester.pumpAndSettle();

    expect(find.text('مزود p1'), findsNothing);
    expect(find.text('لا توجد عناصر مفضلة'), findsOneWidget);
    expect(repository.toggleCalls, ['provider:p1']);
  });

  testWidgets('the removed item disappears while the catalog keeps it', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    repository.data['u-a'] = {
      'services': [_service('s1')],
      'providers': <dynamic>[],
    };
    final container = _newContainer(repository);
    await _pump(tester, container);

    await tester.tap(
      find.descendant(
        of: _serviceHeart(0),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ServiceCard), findsNothing);
    expect(repository.catalogServices, contains('s1'));
    expect(repository.toggleCalls, ['service:s1']);
  });

  testWidgets('removing the last item shows the empty state', (tester) async {
    final repository = _FakeCustomerRepository();
    repository.data['u-a'] = {
      'services': [_service('s1')],
      'providers': [_provider('p1')],
    };
    final container = _newContainer(repository);
    await _pump(tester, container);

    await tester.tap(
      find.descendant(
        of: _serviceHeart(0),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(FavoriteToggleButton),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('لا توجد عناصر مفضلة'), findsOneWidget);
  });

  testWidgets('a failed removal keeps the item visible with a message', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    repository.data['u-a'] = {
      'services': [_service('s1')],
      'providers': <dynamic>[],
    };
    repository.toggleError = const ApiException(NetworkFailure());
    final container = _newContainer(repository);
    await _pump(tester, container);

    await tester.tap(
      find.descendant(
        of: _serviceHeart(0),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('خدمة s1'), findsWidgets);
    expect(find.byType(ServiceCard), findsOneWidget);
    expect(find.text('تعذر الاتصال بالخادم. تحقق من الشبكة.'), findsOneWidget);
    expect(find.text('لا توجد عناصر مفضلة'), findsNothing);
  });

  testWidgets('a retried removal succeeds after a failure', (tester) async {
    final repository = _FakeCustomerRepository();
    repository.data['u-a'] = {
      'services': [_service('s1')],
      'providers': <dynamic>[],
    };
    repository.toggleError = const ApiException(NetworkFailure());
    final container = _newContainer(repository);
    await _pump(tester, container);

    await tester.tap(
      find.descendant(
        of: _serviceHeart(0),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ServiceCard), findsOneWidget);

    repository.toggleError = null;
    await tester.tap(
      find.descendant(
        of: _serviceHeart(0),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ServiceCard), findsNothing);
    expect(repository.toggleCalls, ['service:s1', 'service:s1']);
  });

  testWidgets('several services can be removed one after another', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    repository.data['u-a'] = {
      'services': [_service('s1'), _service('s2')],
      'providers': <dynamic>[],
    };
    final container = _newContainer(repository);
    await _pump(tester, container);

    expect(find.byType(ServiceCard), findsNWidgets(2));

    await tester.tap(
      find.descendant(
        of: _serviceHeart(0),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ServiceCard), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: _serviceHeart(0),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ServiceCard), findsNothing);
    expect(repository.toggleCalls, ['service:s1', 'service:s2']);
  });

  testWidgets('removal sends only the toggle request, no extra API call', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    repository.data['u-a'] = {
      'services': [_service('s1')],
      'providers': <dynamic>[],
    };
    final container = _newContainer(repository);
    await _pump(tester, container);
    // Initial list load only.
    expect(repository.favoritesCalls, 1);

    await tester.tap(
      find.descendant(
        of: _serviceHeart(0),
        matching: find.byType(IconButton),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.toggleCalls, ['service:s1']);
    // One toggle + its single follow-up refresh; nothing else.
    expect(repository.favoritesCalls, 2);
  });

  testWidgets('pull-to-refresh still reloads the list', (tester) async {
    final repository = _FakeCustomerRepository();
    repository.data['u-a'] = {
      'services': [_service('s1')],
      'providers': <dynamic>[],
    };
    final container = _newContainer(repository);
    await _pump(tester, container);

    expect(find.text('خدمة s1'), findsWidgets);

    repository.data['u-a'] = {
      'services': [_service('s2')],
      'providers': <dynamic>[],
    };

    final refresh = tester.state<RefreshIndicatorState>(
      find.byType(RefreshIndicator),
    );
    // Do not await show() before pumping: its animation only advances with
    // frames, so awaiting first would deadlock the fake-async test clock.
    final shown = refresh.show().catchError((_) {});
    await tester.pump();
    await tester.pumpAndSettle();
    await shown;

    expect(find.text('خدمة s2'), findsWidgets);
    expect(find.text('خدمة s1'), findsNothing);
  });

  testWidgets('an item added on details appears after returning', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    repository.data['u-a'] = {
      'services': [_service('s1')],
      'providers': <dynamic>[],
    };
    final container = _newContainer(repository);
    await _pump(tester, container);

    // Open the service details through the card body.
    await tester.tap(find.text('خدمة s1').first);
    await tester.pumpAndSettle();
    expect(find.text('service-details'), findsOneWidget);

    await tester.tap(find.text('add-s2'));
    await tester.pumpAndSettle();

    // Back on the favorites screen, the newly added service is listed.
    expect(find.text('المفضلة'), findsOneWidget);
    expect(find.text('خدمة s2'), findsWidgets);
  });

  testWidgets('switching accounts never shows the previous account data', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    repository.data['u-a'] = {
      'services': [_service('s1')],
      'providers': <dynamic>[],
    };
    repository.data['u-b'] = {
      'services': <dynamic>[],
      'providers': [_provider('p1')],
    };
    final container = _newContainer(repository);
    await _pump(tester, container);

    expect(find.text('خدمة s1'), findsWidgets);

    repository.account = 'u-b';
    container.read(_testSessionProvider.notifier).state = _accountB;
    await tester.pumpAndSettle();

    expect(find.text('خدمة s1'), findsNothing);
    expect(find.text('مزود p1'), findsOneWidget);
  });

  testWidgets('a failed list load shows a message and retries successfully', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    repository.favoritesError = const ApiException(NetworkFailure());
    final container = _newContainer(repository);
    await _pump(tester, container);

    expect(find.text('تعذر تحميل المفضلة'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);

    repository.favoritesError = null;
    repository.data['u-a'] = {
      'services': [_service('s1')],
      'providers': <dynamic>[],
    };
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(find.text('تعذر تحميل المفضلة'), findsNothing);
    expect(find.text('خدمة s1'), findsWidgets);
  });
}
