import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber_flutter/data/repositories/catalog_repository.dart';
import 'package:saber_flutter/modules/customer/screens/home/offers_screen.dart';
import 'package:saber_flutter/modules/customer/screens/home/providers_directory_screen.dart';
import 'package:saber_flutter/modules/customer/screens/provider_profile_screen.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';

class _FakeOffers extends OffersCatalogController {
  _FakeOffers(this._state);

  final OffersCatalogState _state;

  @override
  Future<OffersCatalogState> build() async => _state;
}

class _FakeDirectory extends ProviderDirectoryController {
  _FakeDirectory(this._state);

  final ProviderDirectoryState _state;

  @override
  Future<ProviderDirectoryState> build(ProviderDirectoryFilters params) async =>
      _state;
}

/// Empty, already-loaded favorites so the provider card renders without a
/// signed-in session (the profile screen only looks the state up).
class _EmptyFavorites extends CustomerFavoritesController {
  @override
  AsyncValue<Map<String, dynamic>> build() => const AsyncData(
    <String, dynamic>{'providers': <dynamic>[], 'services': <dynamic>[]},
  );
}

Widget _wrap(List<Override> overrides, Widget child) => ProviderScope(
      overrides: [
        // The favorite heart resolves its lock keys from the account session;
        // these screens do not need a real login.
        sessionScopeProvider.overrideWithValue(
          const SessionScope(isAuthenticated: false),
        ),
        ...overrides,
      ],
      child: MaterialApp(home: child),
    );

void main() {
  testWidgets('offers screen shows the real empty state', (tester) async {
    await tester.pumpWidget(
      _wrap(
        [
          offersCatalogProvider.overrideWith(
            () => _FakeOffers(
              const OffersCatalogState(
                items: [],
                currentPage: 1,
                hasMore: false,
                total: 0,
              ),
            ),
          ),
        ],
        const OffersScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('لا توجد عروض متاحة حالياً'), findsOneWidget);
  });

  testWidgets('offer card renders only API-backed fields', (tester) async {
    const offer = OfferItem(
      id: 'o1',
      slug: 'offer-1',
      title: 'عرض اختبار',
      description: 'وصف العرض',
      discountType: 'percentage',
      discountValue: 25,
      discountPercent: 25,
      minPurchase: 100,
      startDate: '2026-11-01',
      endDate: '2026-11-30',
      isRunning: true,
    );

    await tester.pumpWidget(
      _wrap(
        [
          offersCatalogProvider.overrideWith(
            () => _FakeOffers(
              const OffersCatalogState(
                items: [offer],
                currentPage: 1,
                hasMore: false,
                total: 1,
              ),
            ),
          ),
        ],
        const OffersScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('عرض اختبار'), findsOneWidget);
    expect(find.text('وصف العرض'), findsOneWidget);
    expect(find.text('-25%'), findsOneWidget);
    expect(find.text('الحد الأدنى للشراء: 100'), findsOneWidget);
    expect(find.text('من 2026-11-01 إلى 2026-11-30'), findsOneWidget);
  });

  testWidgets('providers directory shows a filter-aware empty state',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        [
          citiesProvider.overrideWith((ref) async => <Map<String, dynamic>>[]),
          providerDirectoryProvider.overrideWith(
            () => _FakeDirectory(
              const ProviderDirectoryState(
                items: [],
                currentPage: 1,
                hasMore: false,
                total: 0,
              ),
            ),
          ),
        ],
        const ProvidersDirectoryScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('لا يوجد مزودون مطابقون'), findsOneWidget);
  });

  testWidgets('provider profile renders the real portfolios gallery',
      (tester) async {
    final profile = <String, dynamic>{
      'provider': {
        'id': 'p1',
        'business_name': 'مزود تجريبي',
        'average_rating': '4.5',
        'total_reviews': 3,
        'total_bookings': 10,
        'is_verified': true,
        'city': 'عدن',
      },
      'services': <dynamic>[],
      'portfolios': [
        {
          'id': 'pf1',
          'title': 'تركيب مطبخ',
          'category': 'نجارة',
          'description': 'عمل منجز',
          'image': null,
        },
      ],
      'reviews': <dynamic>[],
    };

    await tester.pumpWidget(
      _wrap(
        [
          publicProviderProfileProvider.overrideWith((ref, id) async => profile),
          customerFavoritesProvider.overrideWith(_EmptyFavorites.new),
        ],
        const ProviderProfileScreen(id: 'p1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('معرض الأعمال'), findsOneWidget);
    expect(find.text('تركيب مطبخ'), findsOneWidget);
    expect(find.text('نجارة'), findsOneWidget);
  });
}
