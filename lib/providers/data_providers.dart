import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../data/repositories/catalog_repository.dart';

// ---------------------------------------------------------------------------
// Public catalog
// ---------------------------------------------------------------------------

final homeFeedProvider = FutureProvider<HomeFeed>(
  (ref) => ref.watch(catalogRepositoryProvider).home(),
);

final popularSearchesProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(catalogRepositoryProvider).popularSearches(),
);

final adsProvider = FutureProvider<List<AdBanner>>(
  (ref) => ref.watch(catalogRepositoryProvider).ads(),
);

final categoriesProvider = FutureProvider<List<CategoryItem>>(
  (ref) => ref.watch(catalogRepositoryProvider).categories(),
);

final servicesProvider = FutureProvider.autoDispose
    .family<List<dynamic>, ({String? q, String? categoryId, String? sort})>(
      (ref, params) => ref
          .watch(catalogRepositoryProvider)
          .services(
            q: params.q,
            categoryId: params.categoryId,
            sort: params.sort,
          ),
    );

final providersCatalogProvider = FutureProvider.autoDispose
    .family<List<dynamic>, ({String? cityId, int? page})>(
      (ref, params) => ref
          .watch(catalogRepositoryProvider)
          .providers(cityId: params.cityId, page: params.page),
    );

final publicProviderProfileProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>(
      (ref, id) => ref.watch(catalogRepositoryProvider).providerProfileFull(id),
    );

final citiesProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(catalogRepositoryProvider).cities(),
);

final faqsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(catalogRepositoryProvider).faqs(),
);

// ---------------------------------------------------------------------------
// Customer
// ---------------------------------------------------------------------------

final customerMeProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.watch(customerRepositoryProvider).me(),
);

final customerAddressesProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(customerRepositoryProvider).addresses(),
);

final customerBookingsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String?>(
      (ref, status) =>
          ref.watch(customerRepositoryProvider).bookings(status: status),
    );

final customerBookingProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>(
      (ref, id) => ref.watch(customerRepositoryProvider).booking(id),
    );

final bookingTrackProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>(
      (ref, id) => ref.watch(customerRepositoryProvider).trackBooking(id),
    );

final customerPaymentsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(customerRepositoryProvider).payments(),
);

final customerWalletProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.watch(customerRepositoryProvider).wallet(),
);

final walletTransactionsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(customerRepositoryProvider).walletTransactions(),
);

final customerFavoritesProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.watch(customerRepositoryProvider).favorites(),
);

final customerReviewsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(customerRepositoryProvider).reviews(),
);

final customerComplaintsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(customerRepositoryProvider).complaints(),
);

final customerConversationsProvider =
    FutureProvider<List<Map<String, dynamic>>>(
      (ref) => ref.watch(customerRepositoryProvider).conversations(),
    );

final customerConversationProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>(
      (ref, id) => ref.watch(customerRepositoryProvider).conversation(id),
    );

final customerNotificationsProvider =
    FutureProvider<List<Map<String, dynamic>>>(
      (ref) => ref.watch(customerRepositoryProvider).notifications(),
    );

final unreadNotificationsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(customerRepositoryProvider).unreadNotifications(),
);

final customerCouponsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(customerRepositoryProvider).coupons(),
);

/// Filters accepted by the customer search screen.
typedef CustomerSearchFilters = ({
  String q,
  String? categoryId,
  String? cityId,
  double? minPrice,
  double? maxPrice,
  double? minRating,
  double? latitude,
  double? longitude,
  double? radiusKm,
  String? sort,
});

/// Accumulated search results across every page loaded so far.
class CustomerSearchState {
  const CustomerSearchState({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.isLoadingMore = false,
  });

  final List<Map<String, dynamic>> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool isLoadingMore;

  bool get hasMore => currentPage < lastPage;

  CustomerSearchState copyWith({bool? isLoadingMore}) => CustomerSearchState(
    items: items,
    currentPage: currentPage,
    lastPage: lastPage,
    total: total,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

/// Paginated customer search: loads page 1 on build, then appends further
/// pages on demand via [loadMore].
class CustomerSearchController
    extends
        AutoDisposeFamilyAsyncNotifier<
          CustomerSearchState,
          CustomerSearchFilters
        > {
  bool _disposed = false;

  Map<String, dynamic> _filters(CustomerSearchFilters params) => {
    if (params.categoryId != null) 'category_id': params.categoryId,
    if (params.cityId != null) 'city_id': params.cityId,
    if (params.minPrice != null) 'min_price': params.minPrice,
    if (params.maxPrice != null) 'max_price': params.maxPrice,
    if (params.minRating != null) 'min_rating': params.minRating,
    if (params.latitude != null) 'latitude': params.latitude,
    if (params.longitude != null) 'longitude': params.longitude,
    if (params.radiusKm != null) 'radius_km': params.radiusKm,
    if (params.sort != null) 'sort': params.sort,
    'type': 'services',
  };

  @override
  Future<CustomerSearchState> build(CustomerSearchFilters params) async {
    _disposed = false;
    ref.onDispose(() => _disposed = true);

    final page = await ref
        .watch(customerRepositoryProvider)
        .search(params.q, filters: _filters(params), page: 1);

    return CustomerSearchState(
      items: page.items,
      currentPage: page.currentPage,
      lastPage: page.lastPage,
      total: page.total,
    );
  }

  /// Appends the next page. No-op while a page is in flight, once the last
  /// page is reached, or while page 1 is still loading.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final next = await ref
          .read(customerRepositoryProvider)
          .search(arg.q, filters: _filters(arg), page: current.currentPage + 1);

      if (_disposed) return;
      final latest = state.valueOrNull ?? current;
      state = AsyncData(
        CustomerSearchState(
          items: [...latest.items, ...next.items],
          currentPage: next.currentPage,
          lastPage: next.lastPage,
          total: next.total,
        ),
      );
    } catch (_) {
      if (_disposed) return;
      state = AsyncData(current.copyWith(isLoadingMore: false));
      rethrow;
    }
  }
}

final customerSearchProvider = AsyncNotifierProvider.autoDispose
    .family<
      CustomerSearchController,
      CustomerSearchState,
      CustomerSearchFilters
    >(CustomerSearchController.new);

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final providerDashboardProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.watch(providerRepositoryProvider).dashboard(),
);

final providerProfileProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.watch(providerRepositoryProvider).profile(),
);

final verificationStatusProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.watch(providerRepositoryProvider).verificationStatus(),
);

final providerServicesProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(providerRepositoryProvider).services(),
);

final providerBookingsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, ({String? status, String? date})>(
      (ref, params) => ref
          .watch(providerRepositoryProvider)
          .bookings(status: params.status, date: params.date),
    );

final providerBookingProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>(
      (ref, id) => ref.watch(providerRepositoryProvider).booking(id),
    );

final providerAvailabilityProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.watch(providerRepositoryProvider).availability(),
);

final providerPortfolioProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(providerRepositoryProvider).portfolio(),
);

final providerWalletProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.watch(providerRepositoryProvider).wallet(),
);

final providerWithdrawalsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(providerRepositoryProvider).withdrawals(),
);

final providerReviewsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(providerRepositoryProvider).reviews(),
);

final providerConversationsProvider =
    FutureProvider<List<Map<String, dynamic>>>(
      (ref) => ref.watch(providerRepositoryProvider).conversations(),
    );

final providerConversationProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>(
      (ref, id) => ref.watch(providerRepositoryProvider).conversation(id),
    );

final providerNotificationsProvider =
    FutureProvider<List<Map<String, dynamic>>>(
      (ref) => ref.watch(providerRepositoryProvider).notifications(),
    );

final serviceRequestsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String?>(
      (ref, type) =>
          ref.watch(providerRepositoryProvider).serviceRequests(type: type),
    );

final bookingsReportProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, ({String? from, String? to})>(
      (ref, params) => ref
          .watch(providerRepositoryProvider)
          .bookingsReport(from: params.from, to: params.to),
    );

final revenueReportProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, ({String? from, String? to})>(
      (ref, params) => ref
          .watch(providerRepositoryProvider)
          .revenueReport(from: params.from, to: params.to),
    );
