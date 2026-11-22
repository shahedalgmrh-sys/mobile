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
import 'package:saber_flutter/modules/customer/screens/home/home_screen.dart';
import 'package:saber_flutter/modules/customer/screens/home/providers_directory_screen.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/favorite_toggle_button.dart';

ApiClient _dummyClient() => ApiClient(
  dio: Dio(),
  baseUrl: 'http://localhost/api',
  appVersion: '1.0.0+0',
  storage: SecureStorage(),
);

class _FakeCustomerRepository extends CustomerRepository {
  _FakeCustomerRepository([Set<String>? favorites])
    : favoriteKeys = favorites ?? <String>{},
      super(CustomerRemoteSource(_dummyClient()));

  final Set<String> favoriteKeys;
  final List<String> calls = [];
  final Map<String, Completer<void>> gates = {};
  Completer<void>? favoritesGate;
  Object? toggleError;

  @override
  Future<Map<String, dynamic>> favorites() async {
    final gate = favoritesGate;
    if (gate != null) await gate.future;
    List<Map<String, dynamic>> bucket(String prefix) => [
      for (final key in favoriteKeys)
        if (key.startsWith(prefix))
          {'id': key.substring(prefix.length)},
    ];
    return {
      'services': bucket('service:'),
      'providers': bucket('provider:'),
    };
  }

  Future<bool> _toggle(String key) async {
    calls.add(key);
    final gate = gates[key];
    if (gate != null) await gate.future;
    final failure = toggleError;
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

const _signedIn = SessionScope(
  isAuthenticated: true,
  userId: 'u-1',
  generation: 1,
);

ProviderModel _provider(String id, {String userId = 'user-9'}) => ProviderModel(
  id: id,
  userId: userId,
  businessName: 'مزود $id',
  ratingAvg: 4.5,
  totalReviews: 3,
  servicesCount: 4,
  completedBookings: 9,
  city: 'عدن',
  isVerified: true,
);

GoRouter _router(String initial, Widget root) => GoRouter(
  initialLocation: initial,
  routes: [
    GoRoute(path: initial, builder: (_, __) => root),
    GoRoute(
      path: '/home/providers/:id',
      builder: (_, state) => Scaffold(
        body: Center(
          child: Text('profile:${state.pathParameters['id']}'),
        ),
      ),
    ),
  ],
);

Widget _app({
  required GoRouter router,
  required List<Override> overrides,
}) => ProviderScope(
  overrides: [
    appConfigProvider.overrideWithValue(AppConfig.customer()),
    sessionScopeProvider.overrideWithValue(_signedIn),
    unreadNotificationsProvider.overrideWith(_FakeUnread.new),
    ...overrides,
  ],
  child: MaterialApp.router(
    routerConfig: router,
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
  ),
);

Widget _home(_FakeCustomerRepository repository, List<ProviderModel> providers) =>
    _app(
      router: _router('/home', const HomeScreen()),
      overrides: [
        customerRepositoryProvider.overrideWithValue(repository),
        homeFeedProvider.overrideWith(
          (ref) async => HomeFeed(featuredProviders: providers),
        ),
      ],
    );

Widget _directory(
  _FakeCustomerRepository repository,
  List<ProviderModel> providers,
) => _app(
  router: _router('/directory', const ProvidersDirectoryScreen()),
  overrides: [
    customerRepositoryProvider.overrideWithValue(repository),
    citiesProvider.overrideWith((ref) async => <Map<String, dynamic>>[]),
    providerDirectoryProvider.overrideWith(
      () => _FakeDirectory(
        ProviderDirectoryState(
          items: providers,
          currentPage: 1,
          hasMore: false,
          total: providers.length,
        ),
      ),
    ),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home featured provider cards expose the favorite heart', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = _FakeCustomerRepository();
    await tester.pumpWidget(_home(repository, [_provider('prov-1')]));
    await tester.pumpAndSettle();

    expect(find.byType(FavoriteToggleButton), findsOneWidget);
    expect(
      tester.widget<FavoriteToggleButton>(find.byType(FavoriteToggleButton)).id,
      'prov-1',
    );
    expect(
      tester.widget<FavoriteToggleButton>(find.byType(FavoriteToggleButton)).isProvider,
      isTrue,
    );
  });

  testWidgets('directory provider cards expose the favorite heart', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    await tester.pumpWidget(_directory(repository, [_provider('prov-1')]));
    await tester.pumpAndSettle();

    expect(find.byType(FavoriteToggleButton), findsOneWidget);
    expect(
      tester.widget<FavoriteToggleButton>(find.byType(FavoriteToggleButton)).id,
      'prov-1',
    );
  });

  testWidgets('the heart sends provider.id, never provider.user.id', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = _FakeCustomerRepository();
    await tester.pumpWidget(
      _home(repository, [_provider('prov-1', userId: 'user-9')]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FavoriteToggleButton));
    await tester.pumpAndSettle();

    expect(repository.calls, ['provider:prov-1']);
    expect(repository.calls.single, isNot(contains('user-9')));
  });

  testWidgets('the heart reflects the loaded favorites list', (tester) async {
    final repository = _FakeCustomerRepository({'provider:prov-1'});
    await tester.pumpWidget(_directory(repository, [_provider('prov-1')]));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('tapping the heart never opens the provider profile', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    await tester.pumpWidget(_directory(repository, [_provider('prov-1')]));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FavoriteToggleButton));
    await tester.pumpAndSettle();

    expect(find.text('profile:prov-1'), findsNothing);
    expect(repository.calls, ['provider:prov-1']);
  });

  testWidgets('tapping the directory card body opens the provider profile', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    await tester.pumpWidget(_directory(repository, [_provider('prov-1')]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('مزود prov-1'));
    await tester.pumpAndSettle();

    expect(find.text('profile:prov-1'), findsOneWidget);
    expect(repository.calls, isEmpty);
  });

  testWidgets('tapping the home card body opens the provider profile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = _FakeCustomerRepository();
    await tester.pumpWidget(_home(repository, [_provider('prov-1')]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('مزود prov-1'));
    await tester.pumpAndSettle();

    expect(find.text('profile:prov-1'), findsOneWidget);
    expect(repository.calls, isEmpty);
  });

  testWidgets('one provider pending keeps other provider cards interactive', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    final gate = Completer<void>();
    repository.gates['provider:prov-1'] = gate;

    await tester.pumpWidget(
      _directory(repository, [_provider('prov-1'), _provider('prov-2')]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FavoriteToggleButton).at(0));
    await tester.pump();

    final hearts = find.byType(FavoriteToggleButton);
    expect(
      tester
          .widget<IconButton>(
            find.descendant(
              of: hearts.at(0),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<IconButton>(
            find.descendant(
              of: hearts.at(1),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed,
      isNotNull,
    );

    await tester.tap(
      find.descendant(of: hearts.at(1), matching: find.byType(IconButton)),
    );
    await tester.pump();

    expect(repository.calls, ['provider:prov-1', 'provider:prov-2']);

    gate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('an unknown favorites list disables the provider heart', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    final gate = Completer<void>();
    repository.favoritesGate = gate;

    await tester.pumpWidget(_directory(repository, [_provider('prov-1')]));
    await tester.pump();

    expect(find.byTooltip('جارٍ تحميل المفضلة'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.descendant(
              of: find.byType(FavoriteToggleButton),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.byType(FavoriteToggleButton));
    await tester.pump();
    expect(repository.calls, isEmpty);

    gate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('a failed provider toggle keeps the state and allows a retry', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    repository.toggleError = const ApiException(NetworkFailure());

    await tester.pumpWidget(_directory(repository, [_provider('prov-1')]));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FavoriteToggleButton));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.text('تعذر الاتصال بالخادم. تحقق من الشبكة.'), findsOneWidget);

    repository.toggleError = null;
    await tester.tap(find.byType(FavoriteToggleButton));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(repository.calls, ['provider:prov-1', 'provider:prov-1']);
  });
}
