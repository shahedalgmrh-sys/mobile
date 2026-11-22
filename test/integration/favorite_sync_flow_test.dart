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
import 'package:saber_flutter/data/repositories/catalog_repository.dart';
import 'package:saber_flutter/data/repositories/customer_repository.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';
import 'package:saber_flutter/models/app_config.dart';
import 'package:saber_flutter/models/provider.dart';
import 'package:saber_flutter/models/service.dart';
import 'package:saber_flutter/modules/customer/screens/favorites_screen.dart';
import 'package:saber_flutter/modules/customer/screens/home/home_screen.dart';
import 'package:saber_flutter/modules/customer/screens/home/providers_directory_screen.dart';
import 'package:saber_flutter/modules/customer/screens/home/search_screen.dart';
import 'package:saber_flutter/modules/customer/screens/provider_profile_screen.dart';
import 'package:saber_flutter/modules/customer/screens/service_details_screen.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/providers/location_provider.dart';
import 'package:saber_flutter/shared/widgets/favorite_toggle_button.dart';
import 'package:saber_flutter/shared/widgets/service_card.dart';

ApiClient _dummyClient() => ApiClient(
  dio: Dio(),
  baseUrl: 'http://localhost/api',
  appVersion: '1.0.0+0',
  storage: SecureStorage(),
);

Map<String, dynamic> _serviceJson(String id) => {
  'id': id,
  'slug': 'slug-$id',
  'name': 'خدمة $id',
  'price': 100,
  'currency': 'SAR',
  'average_rating': 4.5,
  'review_count': 3,
};

Map<String, dynamic> _providerJson(String id) => {
  'id': id,
  'business_name': 'مزود $id',
  'average_rating': '4.5',
};

/// Per-account favorites store that mirrors the real nested list envelope
/// `{services: {data: [...]}, providers: {data: [...]}}`.
class _FakeCustomerRepository extends CustomerRepository {
  _FakeCustomerRepository() : super(CustomerRemoteSource(_dummyClient()));

  String account = 'u-a';
  final Map<String, Map<String, List<Map<String, dynamic>>>> data = {
    'u-a': {'services': <Map<String, dynamic>>[], 'providers': <Map<String, dynamic>>[]},
    'u-b': {'services': <Map<String, dynamic>>[], 'providers': <Map<String, dynamic>>[]},
  };

  final List<String> toggleCalls = [];
  final Map<String, Completer<void>> toggleGates = {};
  Object? toggleError;

  int favoritesCalls = 0;

  /// Makes only that 1-based favorites call fail; later calls succeed.
  int? failFavoritesCallAt;

  Completer<void>? favoritesGate;

  void seedService(String id, {String account = 'u-a'}) {
    data[account]!['services']!.add(_serviceJson(id));
  }

  void seedProvider(String id, {String account = 'u-a'}) {
    data[account]!['providers']!.add(_providerJson(id));
  }

  @override
  Future<Map<String, dynamic>> favorites() async {
    final accountAtCall = account;
    favoritesCalls++;
    final gate = favoritesGate;
    if (gate != null) await gate.future;
    if (failFavoritesCallAt == favoritesCalls) {
      throw const ApiException(NetworkFailure());
    }
    final buckets = data[accountAtCall]!;
    return {
      'services': {'data': [...buckets['services']!]},
      'providers': {'data': [...buckets['providers']!]},
    };
  }

  Future<bool> _toggle(String type, String id) async {
    final accountAtCall = account;
    final key = '$type:$id';
    toggleCalls.add(key);
    final gate = toggleGates[accountAtCall];
    if (gate != null) await gate.future;
    final failure = toggleError;
    if (failure != null) throw failure;
    final bucket = data[accountAtCall]![type == 'service' ? 'services' : 'providers']!;
    final wasFavorite = bucket.any((item) => item['id'] == id);
    bucket.removeWhere((item) => item['id'] == id);
    if (!wasFavorite) {
      bucket.add(type == 'service' ? _serviceJson(id) : _providerJson(id));
    }
    return !wasFavorite;
  }

  @override
  Future<bool> toggleServiceFavorite(String serviceId) =>
      _toggle('service', serviceId);

  @override
  Future<bool> toggleProviderFavorite(String providerId) =>
      _toggle('provider', providerId);

  @override
  Future<int> unreadNotificationsCount() async => 0;
}

class _FakeUnread extends UnreadNotificationsController {
  @override
  AsyncValue<int> build() => const AsyncData(0);
}

class _FakeDirectory extends ProviderDirectoryController {
  _FakeDirectory(this._state);

  final ProviderDirectoryState _state;

  @override
  Future<ProviderDirectoryState> build(ProviderDirectoryFilters params) async =>
      _state;
}

class _FakeSearch extends CustomerSearchController {
  _FakeSearch(this._items);

  final List<Map<String, dynamic>> _items;

  @override
  Future<CustomerSearchState> build(CustomerSearchFilters params) async =>
      CustomerSearchState(
        items: _items,
        currentPage: 1,
        lastPage: 1,
        total: _items.length,
      );
}

class _FakeLocation extends AppLocationNotifier {
  @override
  Future<AppLocation?> build() async => null;
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

Service _service(String id) => Service(
  id: id,
  slug: 'slug-$id',
  titleAr: 'خدمة $id',
  titleEn: 'Service $id',
  basePrice: 100,
  currencyCode: 'SAR',
  categoryId: 'cat-1',
  ratingAvg: 4.5,
  reviewsCount: 3,
);

ProviderModel _provider(String id) => ProviderModel(
  id: id,
  userId: 'user-$id',
  businessName: 'مزود $id',
  ratingAvg: 4.5,
  totalReviews: 3,
  servicesCount: 2,
  completedBookings: 5,
  city: 'عدن',
  isVerified: true,
);

Map<String, dynamic> _providerProfile(String id) => {
  'provider': {
    'id': id,
    'user_id': 'user-$id',
    'business_name': 'مزود $id',
    'average_rating': '4.5',
    'total_reviews': 3,
  },
  'services': <dynamic>[],
  'portfolios': <dynamic>[],
  'reviews': <dynamic>[],
};

ProviderContainer _newContainer({
  required _FakeCustomerRepository repository,
  List<Service> popular = const [],
  List<ProviderModel> featuredProviders = const [],
  List<ProviderModel> directory = const [],
  List<Map<String, dynamic>> searchItems = const [],
}) {
  final container = ProviderContainer(
    overrides: [
      appConfigProvider.overrideWithValue(AppConfig.customer()),
      sessionScopeProvider.overrideWith(
        (ref) => ref.watch(_testSessionProvider),
      ),
      customerRepositoryProvider.overrideWithValue(repository),
      unreadNotificationsProvider.overrideWith(_FakeUnread.new),
      appLocationProvider.overrideWith(_FakeLocation.new),
      adsProvider.overrideWith((ref) async => <AdBanner>[]),
      categoriesProvider.overrideWith((ref) async => <CategoryItem>[]),
      citiesProvider.overrideWith((ref) async => <Map<String, dynamic>>[]),
      popularSearchesProvider.overrideWith((ref) async => <String>[]),
      homeFeedProvider.overrideWith(
        (ref) async => HomeFeed(
          popularServices: popular,
          featuredProviders: featuredProviders,
        ),
      ),
      providerDirectoryProvider.overrideWith(
        () => _FakeDirectory(
          ProviderDirectoryState(
            items: directory,
            currentPage: 1,
            hasMore: false,
            total: directory.length,
          ),
        ),
      ),
      publicProviderProfileProvider.overrideWith(
        (ref, id) async => _providerProfile(id),
      ),
      customerSearchProvider.overrideWith(() => _FakeSearch(searchItems)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

GoRouter _router({String initial = '/home'}) => GoRouter(
  initialLocation: initial,
  routes: [
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/favorites', builder: (_, __) => const FavoritesScreen()),
    GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
    GoRoute(
      path: '/home/providers',
      builder: (_, __) => const ProvidersDirectoryScreen(),
    ),
    GoRoute(
      path: '/home/providers/:id',
      builder: (_, state) =>
          ProviderProfileScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/home/services/:slug',
      builder: (_, state) => ServiceDetailsScreen(
        slug: state.pathParameters['slug']!,
        service: state.extra is Service ? state.extra as Service : null,
      ),
    ),
  ],
);

Widget _app(ProviderContainer container, GoRouter router) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
      ),
    );

Future<void> _pump(
  WidgetTester tester,
  ProviderContainer container,
  GoRouter router,
) async {
  await tester.pumpWidget(_app(container, router));
  await tester.pumpAndSettle();
}

Finder _heart(String id, {bool isProvider = false}) => find.byWidgetPredicate(
  (widget) =>
      widget is FavoriteToggleButton &&
      widget.id == id &&
      widget.isProvider == isProvider,
);

IconData _iconOf(WidgetTester tester, Finder heart) {
  final icon = tester.widget<Icon>(
    find.descendant(of: heart, matching: find.byType(Icon)),
  );
  return icon.icon!;
}

bool _enabled(WidgetTester tester, Finder heart) =>
    tester
        .widget<IconButton>(
          find.descendant(of: heart, matching: find.byType(IconButton)),
        )
        .onPressed !=
    null;

Future<void> _tapHeart(
  WidgetTester tester,
  Finder heart, {
  bool settle = true,
}) async {
  await tester.tap(
    find.descendant(of: heart, matching: find.byType(IconButton)),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home add → details → favorites agree with one confirmed toggle',
      (tester) async {
    tester.view.physicalSize = const Size(900, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = _FakeCustomerRepository();
    final container = _newContainer(
      repository: repository,
      popular: [_service('s1')],
    );
    final router = _router();
    await _pump(tester, container, router);

    expect(_iconOf(tester, _heart('s1')), Icons.favorite_border);

    await _tapHeart(tester, _heart('s1'));
    expect(repository.toggleCalls, ['service:s1']);
    expect(_iconOf(tester, _heart('s1')), Icons.favorite);

    // The card body still opens the details screen.
    await tester.tap(find.text('خدمة s1').first);
    await tester.pumpAndSettle();
    expect(find.byType(ServiceDetailsScreen), findsOneWidget);
    expect(_iconOf(tester, _heart('s1')), Icons.favorite);

    router.push('/favorites');
    await tester.pumpAndSettle();
    expect(find.text('خدمة s1'), findsWidgets);

    // Exactly one toggle, one initial list load and one post-toggle reconcile:
    // no per-card GET, no duplicate API write.
    expect(repository.toggleCalls, ['service:s1']);
    expect(repository.favoritesCalls, 2);
  });

  testWidgets(
      'provider add → directory → profile → favorites never uses user.id',
      (tester) async {
    tester.view.physicalSize = const Size(900, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = _FakeCustomerRepository();
    final container = _newContainer(
      repository: repository,
      directory: [_provider('p1')],
    );
    final router = _router(initial: '/home/providers');
    await _pump(tester, container, router);

    await _tapHeart(tester, _heart('p1', isProvider: true));
    expect(repository.toggleCalls, ['provider:p1']);
    expect(repository.toggleCalls.single, isNot(contains('user-p1')));
    expect(_iconOf(tester, _heart('p1', isProvider: true)), Icons.favorite);

    // The card body still opens the provider profile.
    await tester.tap(find.text('مزود p1'));
    await tester.pumpAndSettle();
    expect(find.byType(ProviderProfileScreen), findsOneWidget);
    expect(_iconOf(tester, _heart('p1', isProvider: true)), Icons.favorite);

    router.push('/favorites');
    await tester.pumpAndSettle();
    expect(find.text('مزود p1'), findsOneWidget);
    expect(repository.toggleCalls, ['provider:p1']);
  });

  testWidgets('favorites removal reaches the search card and the details',
      (tester) async {
    tester.view.physicalSize = const Size(900, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = _FakeCustomerRepository()..seedService('s1');
    final container = _newContainer(
      repository: repository,
      searchItems: [_serviceJson('s1')],
    );
    final router = _router(initial: '/favorites');
    await _pump(tester, container, router);

    expect(find.byType(ServiceCard), findsOneWidget);
    await _tapHeart(tester, _heart('s1'));
    expect(find.byType(ServiceCard), findsNothing);
    expect(find.text('لا توجد عناصر مفضلة'), findsOneWidget);

    router.push('/search');
    await tester.pumpAndSettle();
    expect(find.byType(ServiceCard), findsOneWidget);
    await tester.ensureVisible(find.byType(ServiceCard));
    expect(_iconOf(tester, _heart('s1')), Icons.favorite_border);

    await tester.tap(find.text('خدمة s1').first);
    await tester.pumpAndSettle();
    expect(find.byType(ServiceDetailsScreen), findsOneWidget);
    expect(_iconOf(tester, _heart('s1')), Icons.favorite_border);
    expect(repository.toggleCalls, ['service:s1']);
  });

  testWidgets('favorites removal reaches the provider profile', (tester) async {
    tester.view.physicalSize = const Size(900, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = _FakeCustomerRepository()..seedProvider('p1');
    final container = _newContainer(repository: repository);
    final router = _router(initial: '/favorites');
    await _pump(tester, container, router);

    await _tapHeart(tester, _heart('p1', isProvider: true));
    expect(find.text('لا توجد عناصر مفضلة'), findsOneWidget);

    router.push('/home/providers/p1');
    await tester.pumpAndSettle();
    expect(find.byType(ProviderProfileScreen), findsOneWidget);
    expect(
      _iconOf(tester, _heart('p1', isProvider: true)),
      Icons.favorite_border,
    );
    expect(repository.toggleCalls, ['provider:p1']);
  });

  testWidgets('a loading favorites list blocks the heart until it loads',
      (tester) async {
    tester.view.physicalSize = const Size(900, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = _FakeCustomerRepository();
    final gate = Completer<void>();
    repository.favoritesGate = gate;
    final container = _newContainer(
      repository: repository,
      popular: [_service('s1')],
    );
    final router = _router();
    await _pump(tester, container, router);

    expect(
      tester.widget<IconButton>(
        find.descendant(
          of: _heart('s1'),
          matching: find.byType(IconButton),
        ),
      ).tooltip,
      'جارٍ تحميل المفضلة',
    );
    expect(_enabled(tester, _heart('s1')), isFalse);

    // A blocked heart swallows the tap: no toggle and no navigation.
    await tester.tap(_heart('s1'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(repository.toggleCalls, isEmpty);
    expect(repository.favoritesCalls, 1);
    expect(find.byType(ServiceDetailsScreen), findsNothing);

    gate.complete();
    await tester.pumpAndSettle();
    expect(_enabled(tester, _heart('s1')), isTrue);
    expect(_iconOf(tester, _heart('s1')), Icons.favorite_border);

    await _tapHeart(tester, _heart('s1'));
    expect(repository.toggleCalls, ['service:s1']);
  });

  testWidgets('a failed favorites list blocks the heart until a reload',
      (tester) async {
    tester.view.physicalSize = const Size(900, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = _FakeCustomerRepository()..failFavoritesCallAt = 1;
    final container = _newContainer(
      repository: repository,
      popular: [_service('s1')],
    );
    final router = _router();
    await _pump(tester, container, router);

    expect(
      tester.widget<IconButton>(
        find.descendant(
          of: _heart('s1'),
          matching: find.byType(IconButton),
        ),
      ).tooltip,
      'تعذر تحميل المفضلة',
    );
    expect(_enabled(tester, _heart('s1')), isFalse);
    await tester.tap(_heart('s1'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(repository.toggleCalls, isEmpty);
    expect(find.byType(ServiceDetailsScreen), findsNothing);

    // Recovery: the reload succeeds, so the heart becomes interactive.
    repository.failFavoritesCallAt = null;
    container.invalidate(customerFavoritesProvider);
    await tester.pumpAndSettle();

    expect(_enabled(tester, _heart('s1')), isTrue);
    expect(_iconOf(tester, _heart('s1')), Icons.favorite_border);

    await _tapHeart(tester, _heart('s1'));
    expect(repository.toggleCalls, ['service:s1']);
  });

  testWidgets('a toggle queued for account A never leaks into account B',
      (tester) async {
    tester.view.physicalSize = const Size(900, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = _FakeCustomerRepository();
    final gate = Completer<void>();
    repository.toggleGates['u-a'] = gate;
    final container = _newContainer(
      repository: repository,
      popular: [_service('s1')],
    );
    final router = _router();
    await _pump(tester, container, router);

    await _tapHeart(tester, _heart('s1'), settle: false);
    expect(repository.toggleCalls, ['service:s1']);
    expect(_enabled(tester, _heart('s1')), isFalse);

    // Switch to account B while A's request is still running.
    repository.account = 'u-b';
    container.read(_testSessionProvider.notifier).state = _accountB;
    await tester.pumpAndSettle();

    // B starts from the server state: no pending lock and no favorite.
    expect(_enabled(tester, _heart('s1')), isTrue);
    expect(_iconOf(tester, _heart('s1')), Icons.favorite_border);

    router.push('/favorites');
    await tester.pumpAndSettle();
    expect(find.text('لا توجد عناصر مفضلة'), findsOneWidget);

    // A's late success is discarded: no mutation reaches B.
    gate.complete();
    await tester.pumpAndSettle();

    expect(find.text('لا توجد عناصر مفضلة'), findsOneWidget);
    expect(repository.data['u-b']!['services'], isEmpty);

    router.pop();
    await tester.pumpAndSettle();

    expect(_iconOf(tester, _heart('s1')), Icons.favorite_border);
    expect(_enabled(tester, _heart('s1')), isTrue);
    expect(repository.toggleCalls, ['service:s1']);
    expect(repository.data['u-a']!['services'], hasLength(1));
  });

  testWidgets(
      'a failed post-toggle refresh is corrected by the next external list',
      (tester) async {
    tester.view.physicalSize = const Size(900, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = _FakeCustomerRepository()..seedService('s2');
    // Call 1 = initial load, call 2 = the toggle's own refresh (fails),
    // call 3 = the user's external pull-to-refresh (succeeds).
    repository.failFavoritesCallAt = 2;
    final container = _newContainer(
      repository: repository,
      popular: [_service('s1')],
    );
    final router = _router();
    await _pump(tester, container, router);

    expect(_iconOf(tester, _heart('s1')), Icons.favorite_border);

    await _tapHeart(tester, _heart('s1'));
    expect(repository.favoritesCalls, 2);
    // The toggle succeeded, so its confirmed value stays despite the failure.
    expect(_iconOf(tester, _heart('s1')), Icons.favorite);

    // Another device removed s1; a later external list is authoritative.
    repository.data['u-a']!['services']!.removeWhere(
      (item) => item['id'] == 's1',
    );

    router.push('/favorites');
    await tester.pumpAndSettle();
    expect(find.text('خدمة s2'), findsWidgets);

    final refresh = tester.state<RefreshIndicatorState>(
      find.byType(RefreshIndicator),
    );
    final shown = refresh.show().catchError((_) {});
    await tester.pump();
    await tester.pumpAndSettle();
    await shown;
    expect(repository.favoritesCalls, 3);

    router.pop();
    await tester.pumpAndSettle();

    // The newest list wins; the stale confirmation is gone without a flicker.
    expect(_iconOf(tester, _heart('s1')), Icons.favorite_border);
  });
}
