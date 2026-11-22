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
import 'package:saber_flutter/models/service.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/shared/widgets/favorite_toggle_button.dart';
import 'package:saber_flutter/shared/widgets/service_card.dart';

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
  Object? favoritesError;
  Object? toggleError;

  @override
  Future<Map<String, dynamic>> favorites() async {
    final gate = favoritesGate;
    if (gate != null) await gate.future;
    final failure = favoritesError;
    if (failure != null) throw failure;
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

Service _service(String id, {String slug = 'slug-1', String? title}) => Service(
  id: id,
  slug: slug,
  titleAr: title ?? 'خدمة $id',
  titleEn: 'Service $id',
  basePrice: 100,
  currencyCode: 'SAR',
  categoryId: 'cat',
);

Widget _wrap(_FakeCustomerRepository repository, Widget child) => ProviderScope(
  overrides: [
    customerRepositoryProvider.overrideWithValue(repository),
    sessionScopeProvider.overrideWithValue(
      const SessionScope(isAuthenticated: true, userId: 'u-1', generation: 1),
    ),
  ],
  child: MaterialApp(home: Scaffold(body: child)),
);

Finder _heartOf(int index) => find.descendant(
  of: find.byType(ServiceCard).at(index),
  matching: find.byType(FavoriteToggleButton),
);

Finder _heartButtonOf(int index) => find.descendant(
  of: _heartOf(index),
  matching: find.byType(IconButton),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a service card shows the central favorite heart', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    await tester.pumpWidget(
      _wrap(
        repository,
        ListView(children: [ServiceCard(service: _service('svc-1'))]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FavoriteToggleButton), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  testWidgets('the heart reflects the loaded favorites list', (tester) async {
    final repository = _FakeCustomerRepository({'service:svc-1'});
    await tester.pumpWidget(
      _wrap(
        repository,
        ListView(children: [ServiceCard(service: _service('svc-1'))]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
  });

  testWidgets('tapping the heart sends service.id, never the slug', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    await tester.pumpWidget(
      _wrap(
        repository,
        ListView(
          children: [
            ServiceCard(service: _service('svc-1', slug: 'fancy-slug')),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(_heartButtonOf(0));
    await tester.pumpAndSettle();

    expect(repository.calls, ['service:svc-1']);
    expect(repository.calls.single, isNot(contains('fancy-slug')));
    expect(tester.widget<FavoriteToggleButton>(_heartOf(0)).id, 'svc-1');
  });

  testWidgets('the heart ignores a slug-only identity', (tester) async {
    final repository = _FakeCustomerRepository({'service:real-id'});
    await tester.pumpWidget(
      _wrap(
        repository,
        ListView(
          children: [
            ServiceCard(service: _service('real-id', slug: 'slug-only')),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await tester.tap(_heartButtonOf(0));
    await tester.pumpAndSettle();

    expect(repository.calls, ['service:real-id']);
    expect(tester.widget<FavoriteToggleButton>(_heartOf(0)).id, 'real-id');
  });

  testWidgets('tapping the heart does not open the service details', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    var opened = 0;
    await tester.pumpWidget(
      _wrap(
        repository,
        ListView(
          children: [
            ServiceCard(
              service: _service('svc-1'),
              onTap: () => opened++,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(_heartButtonOf(0));
    await tester.pumpAndSettle();

    expect(opened, 0);
    expect(repository.calls, ['service:svc-1']);
  });

  testWidgets('tapping the card body opens the service details', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    var opened = 0;
    await tester.pumpWidget(
      _wrap(
        repository,
        ListView(
          children: [
            ServiceCard(
              service: _service('svc-1'),
              categoryLabel: 'تصنيف',
              onTap: () => opened++,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('خدمة svc-1'));
    await tester.pumpAndSettle();

    expect(opened, 1);
    expect(repository.calls, isEmpty);
  });

  testWidgets('a spinner replaces the heart while the toggle is in flight', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    final gate = Completer<void>();
    repository.gates['service:svc-1'] = gate;

    await tester.pumpWidget(
      _wrap(
        repository,
        ListView(children: [ServiceCard(service: _service('svc-1'))]),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(_heartButtonOf(0));
    await tester.pump();

    expect(
      find.descendant(
        of: _heartOf(0),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    expect(tester.widget<IconButton>(_heartButtonOf(0)).onPressed, isNull);

    gate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('one card pending never disables another card', (tester) async {
    final repository = _FakeCustomerRepository();
    final gate = Completer<void>();
    repository.gates['service:svc-1'] = gate;

    await tester.pumpWidget(
      _wrap(
        repository,
        ListView(
          children: [
            ServiceCard(service: _service('svc-1')),
            ServiceCard(service: _service('svc-2')),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(_heartButtonOf(0));
    await tester.pump();

    expect(tester.widget<IconButton>(_heartButtonOf(0)).onPressed, isNull);
    expect(tester.widget<IconButton>(_heartButtonOf(1)).onPressed, isNotNull);

    await tester.ensureVisible(_heartButtonOf(1));
    await tester.tap(_heartButtonOf(1));
    await tester.pump();

    expect(repository.calls, ['service:svc-1', 'service:svc-2']);

    gate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('an unknown favorites list blocks the card heart', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository();
    final gate = Completer<void>();
    repository.favoritesGate = gate;

    await tester.pumpWidget(
      _wrap(
        repository,
        ListView(children: [ServiceCard(service: _service('svc-1'))]),
      ),
    );
    await tester.pump();

    expect(find.byTooltip('جارٍ تحميل المفضلة'), findsOneWidget);
    expect(tester.widget<IconButton>(_heartButtonOf(0)).onPressed, isNull);

    await tester.tap(_heartButtonOf(0));
    await tester.pump();

    expect(repository.calls, isEmpty);

    gate.complete();
    await tester.pumpAndSettle();
    expect(tester.widget<IconButton>(_heartButtonOf(0)).onPressed, isNotNull);
  });

  testWidgets('a failed toggle keeps the previous card state and message', (
    tester,
  ) async {
    final repository = _FakeCustomerRepository({'service:svc-1'});
    repository.toggleError = const ApiException(NetworkFailure());

    await tester.pumpWidget(
      _wrap(
        repository,
        ListView(children: [ServiceCard(service: _service('svc-1'))]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await tester.tap(_heartButtonOf(0));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.text('تعذر الاتصال بالخادم. تحقق من الشبكة.'), findsOneWidget);
    expect(
      tester.widget<IconButton>(_heartButtonOf(0)).onPressed,
      isNotNull,
    );
  });
}
