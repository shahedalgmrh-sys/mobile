import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/repositories/parsers.dart';
import '../models/provider.dart';
import 'auth_provider.dart';

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

final publicProviderProfileProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>(
      (ref, id) => ref.watch(catalogRepositoryProvider).providerProfileFull(id),
    );

final citiesProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(catalogRepositoryProvider).cities(),
);

/// Areas of a city (public `/cities/{id}/areas`).
final providerCityAreasProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>(
      (ref, cityId) => ref.watch(catalogRepositoryProvider).cityAreas(cityId),
    );

final faqsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(catalogRepositoryProvider).faqs(),
);

/// Filters accepted by the providers directory.
typedef ProviderDirectoryFilters = ({String q, String? cityId});

/// Accumulated providers-directory pages.
class ProviderDirectoryState {
  const ProviderDirectoryState({
    required this.items,
    required this.currentPage,
    required this.hasMore,
    required this.total,
    this.isLoadingMore = false,
  });

  final List<ProviderModel> items;
  final int currentPage;
  final bool hasMore;
  final int total;
  final bool isLoadingMore;

  ProviderDirectoryState copyWith({bool? isLoadingMore}) =>
      ProviderDirectoryState(
        items: items,
        currentPage: currentPage,
        hasMore: hasMore,
        total: total,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

/// Paginated providers directory (public `/providers` endpoint).
class ProviderDirectoryController
    extends
        AutoDisposeFamilyAsyncNotifier<
          ProviderDirectoryState,
          ProviderDirectoryFilters
        > {
  bool _disposed = false;

  @override
  Future<ProviderDirectoryState> build(ProviderDirectoryFilters params) async {
    _disposed = false;
    ref.onDispose(() => _disposed = true);

    final page = await ref
        .watch(catalogRepositoryProvider)
        .providersPage(q: params.q, cityId: params.cityId);

    return ProviderDirectoryState(
      items: page.items,
      currentPage: page.currentPage,
      hasMore: page.hasMore,
      total: page.total,
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final next = await ref
          .read(catalogRepositoryProvider)
          .providersPage(
            q: arg.q,
            cityId: arg.cityId,
            page: current.currentPage + 1,
          );

      if (_disposed) return;
      final latest = state.valueOrNull ?? current;
      state = AsyncData(
        ProviderDirectoryState(
          items: [...latest.items, ...next.items],
          currentPage: next.currentPage,
          hasMore: next.hasMore,
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

final providerDirectoryProvider = AsyncNotifierProvider.autoDispose
    .family<
      ProviderDirectoryController,
      ProviderDirectoryState,
      ProviderDirectoryFilters
    >(ProviderDirectoryController.new);

/// Accumulated offers pages.
class OffersCatalogState {
  const OffersCatalogState({
    required this.items,
    required this.currentPage,
    required this.hasMore,
    required this.total,
    this.isLoadingMore = false,
  });

  final List<OfferItem> items;
  final int currentPage;
  final bool hasMore;
  final int total;
  final bool isLoadingMore;

  OffersCatalogState copyWith({bool? isLoadingMore}) => OffersCatalogState(
    items: items,
    currentPage: currentPage,
    hasMore: hasMore,
    total: total,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

/// Paginated public offers (`/offers`).
class OffersCatalogController
    extends AutoDisposeAsyncNotifier<OffersCatalogState> {
  static const _perPage = 12;
  bool _disposed = false;

  @override
  Future<OffersCatalogState> build() async {
    _disposed = false;
    ref.onDispose(() => _disposed = true);

    final page = await ref
        .watch(catalogRepositoryProvider)
        .offersPage(perPage: _perPage);

    return OffersCatalogState(
      items: page.items,
      currentPage: page.currentPage,
      hasMore: page.hasMore,
      total: page.total,
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final next = await ref
          .read(catalogRepositoryProvider)
          .offersPage(page: current.currentPage + 1, perPage: _perPage);

      if (_disposed) return;
      final latest = state.valueOrNull ?? current;
      state = AsyncData(
        OffersCatalogState(
          items: [...latest.items, ...next.items],
          currentPage: next.currentPage,
          hasMore: next.hasMore,
          total: latest.total + next.items.length,
        ),
      );
    } catch (_) {
      if (_disposed) return;
      state = AsyncData(current.copyWith(isLoadingMore: false));
      rethrow;
    }
  }
}

final offersCatalogProvider =
    AsyncNotifierProvider.autoDispose<
      OffersCatalogController,
      OffersCatalogState
    >(OffersCatalogController.new);

// ---------------------------------------------------------------------------
// Customer — account-scoped data
// ---------------------------------------------------------------------------
//
// Everything below belongs to the signed-in customer. Each provider is rebuilt
// from scratch for every login session:
//   * signed out -> an explicit empty value and no customer API request,
//   * account switch -> no previous value survives into the new loading state,
//   * a response is applied only while the session that started it is still
//     current (logout, switch, 401/session expiry or same-user re-login),
//   * within one session an older request can never overwrite a newer one.
// The public catalog providers above are intentionally left untouched.

/// Thrown when a response arrives after the account session it belongs to has
/// ended. Such a payload must never be rendered as the current account data.
class StaleSessionException implements Exception {
  const StaleSessionException();

  @override
  String toString() => 'StaleSessionException';
}

/// Account-scoped provider state.
///
/// The provider instance stays stable for consumers, but its state is rebuilt
/// from scratch for every login session: the previous account's data is
/// dropped (not even kept as "previous value while loading"), a request that
/// finishes after logout/switch/re-login is ignored even when the server
/// answered successfully, and a signed-out app holds no data at all.
abstract class _SessionScopedController<T> extends Notifier<AsyncValue<T>> {
  int _requestId = 0;
  bool _disposed = false;

  T get emptyValue;
  Future<T> fetch();

  @override
  AsyncValue<T> build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);

    final session = ref.watch(sessionScopeProvider);
    final requestId = ++_requestId;
    if (!session.hasSession) return AsyncData<T>(emptyValue);

    Future<void>.microtask(() => _load(session, requestId));
    return AsyncLoading<T>();
  }

  /// Refetches for the current session. Returns `null` without touching the
  /// provider when [expectedSession] already ended, so a slow toggle from an
  /// old account cannot refresh (or repopulate) a newer account's list.
  Future<T?> refresh({SessionScope? expectedSession}) async {
    if (_disposed) return null;
    final session = ref.read(sessionScopeProvider);
    if (expectedSession != null && !session.sameSession(expectedSession)) {
      return null;
    }

    final requestId = ++_requestId;
    if (!session.hasSession) {
      state = AsyncData<T>(emptyValue);
      return emptyValue;
    }

    try {
      final data = await fetch();
      if (!_isCurrent(session, requestId)) return null;
      state = AsyncData<T>(data);
      return data;
    } catch (error, stackTrace) {
      // A background refresh must not replace already visible data; only an
      // empty state turns into an error.
      if (_isCurrent(session, requestId) && !state.hasValue) {
        state = AsyncError<T>(error, stackTrace);
      }
      rethrow;
    }
  }

  Future<void> _load(SessionScope session, int requestId) async {
    // Already superseded (e.g. an explicit refresh started first): do not
    // issue a duplicate request.
    if (!_isCurrent(session, requestId)) return;
    try {
      final data = await fetch();
      if (!_isCurrent(session, requestId)) return;
      state = AsyncData<T>(data);
    } catch (error, stackTrace) {
      if (!_isCurrent(session, requestId)) return;
      state = AsyncError<T>(error, stackTrace);
    }
  }

  bool _isCurrent(SessionScope session, int requestId) {
    if (_disposed || requestId != _requestId) return false;
    return ref.read(sessionScopeProvider).sameSession(session);
  }
}

/// Same guarantees as [_SessionScopedController] for parameterized providers
/// (booking details, invoices, tracked bookings...).
abstract class _SessionScopedFamilyController<T, Arg>
    extends AutoDisposeFamilyNotifier<AsyncValue<T>, Arg> {
  int _requestId = 0;
  bool _disposed = false;

  T get emptyValue;
  Future<T> fetch(Arg arg);

  @override
  AsyncValue<T> build(Arg arg) {
    _disposed = false;
    ref.onDispose(() => _disposed = true);

    final session = ref.watch(sessionScopeProvider);
    final requestId = ++_requestId;
    if (!session.hasSession) return AsyncData<T>(emptyValue);

    Future<void>.microtask(() => _load(arg, session, requestId));
    return AsyncLoading<T>();
  }

  Future<void> _load(Arg arg, SessionScope session, int requestId) async {
    if (!_isCurrent(session, requestId)) return;
    try {
      final data = await fetch(arg);
      if (!_isCurrent(session, requestId)) return;
      state = AsyncData<T>(data);
    } catch (error, stackTrace) {
      if (!_isCurrent(session, requestId)) return;
      state = AsyncError<T>(error, stackTrace);
    }
  }

  bool _isCurrent(SessionScope session, int requestId) {
    if (_disposed || requestId != _requestId) return false;
    return ref.read(sessionScopeProvider).sameSession(session);
  }
}

final customerMeProvider =
    NotifierProvider<CustomerMeController, AsyncValue<Map<String, dynamic>>>(
      CustomerMeController.new,
    );

class CustomerMeController
    extends _SessionScopedController<Map<String, dynamic>> {
  @override
  Map<String, dynamic> get emptyValue => const <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> fetch() =>
      ref.read(customerRepositoryProvider).me();
}

final customerAddressesProvider =
    NotifierProvider<
      CustomerAddressesController,
      AsyncValue<List<Map<String, dynamic>>>
    >(CustomerAddressesController.new);

class CustomerAddressesController
    extends _SessionScopedController<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> get emptyValue =>
      const <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> fetch() =>
      ref.read(customerRepositoryProvider).addresses();
}

final customerBookingsProvider =
    NotifierProvider.autoDispose.family<
      CustomerBookingsController,
      AsyncValue<List<Map<String, dynamic>>>,
      String?
    >(CustomerBookingsController.new);

class CustomerBookingsController
    extends _SessionScopedFamilyController<List<Map<String, dynamic>>, String?> {
  @override
  List<Map<String, dynamic>> get emptyValue =>
      const <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> fetch(String? status) =>
      ref.read(customerRepositoryProvider).bookings(status: status);
}

/// Total booking count from the paginator meta (not just the loaded page).
final customerBookingsTotalProvider =
    NotifierProvider<CustomerBookingsTotalController, AsyncValue<int>>(
      CustomerBookingsTotalController.new,
    );

class CustomerBookingsTotalController
    extends _SessionScopedController<int> {
  @override
  int get emptyValue => 0;

  @override
  Future<int> fetch() async {
    final envelope = await ref
        .read(customerRepositoryProvider)
        .bookingsPage();
    final meta = asMap(envelope['meta']);
    return toInt(meta['total'], dataList(envelope).length);
  }
}

final customerBookingProvider =
    NotifierProvider.autoDispose.family<
      CustomerBookingController,
      AsyncValue<Map<String, dynamic>>,
      String
    >(CustomerBookingController.new);

class CustomerBookingController
    extends _SessionScopedFamilyController<Map<String, dynamic>, String> {
  @override
  Map<String, dynamic> get emptyValue => const <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> fetch(String id) =>
      ref.read(customerRepositoryProvider).booking(id);
}

final bookingTrackProvider =
    NotifierProvider.autoDispose.family<
      BookingTrackController,
      AsyncValue<Map<String, dynamic>>,
      String
    >(BookingTrackController.new);

class BookingTrackController
    extends _SessionScopedFamilyController<Map<String, dynamic>, String> {
  @override
  Map<String, dynamic> get emptyValue => const <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> fetch(String id) =>
      ref.read(customerRepositoryProvider).trackBooking(id);
}

final customerPaymentsProvider =
    NotifierProvider<
      CustomerPaymentsController,
      AsyncValue<List<Map<String, dynamic>>>
    >(CustomerPaymentsController.new);

class CustomerPaymentsController
    extends _SessionScopedController<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> get emptyValue =>
      const <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> fetch() =>
      ref.read(customerRepositoryProvider).payments();
}

final paymentInvoiceProvider =
    NotifierProvider.autoDispose.family<
      PaymentInvoiceController,
      AsyncValue<Map<String, dynamic>>,
      String
    >(PaymentInvoiceController.new);

class PaymentInvoiceController
    extends _SessionScopedFamilyController<Map<String, dynamic>, String> {
  @override
  Map<String, dynamic> get emptyValue => const <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> fetch(String paymentId) =>
      ref.read(customerRepositoryProvider).invoice(paymentId);
}

final customerWalletProvider =
    NotifierProvider<CustomerWalletController, AsyncValue<Map<String, dynamic>>>(
      CustomerWalletController.new,
    );

class CustomerWalletController
    extends _SessionScopedController<Map<String, dynamic>> {
  @override
  Map<String, dynamic> get emptyValue => const <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> fetch() =>
      ref.read(customerRepositoryProvider).wallet();
}

final walletTransactionsProvider =
    NotifierProvider<
      WalletTransactionsController,
      AsyncValue<List<Map<String, dynamic>>>
    >(WalletTransactionsController.new);

class WalletTransactionsController
    extends _SessionScopedController<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> get emptyValue =>
      const <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> fetch() =>
      ref.read(customerRepositoryProvider).walletTransactions();
}

final customerFavoritesProvider =
    NotifierProvider<
      CustomerFavoritesController,
      AsyncValue<Map<String, dynamic>>
    >(CustomerFavoritesController.new);

class CustomerFavoritesController
    extends _SessionScopedController<Map<String, dynamic>> {
  @override
  Map<String, dynamic> get emptyValue => const <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> fetch() =>
      ref.read(customerRepositoryProvider).favorites();
}

final customerReviewsProvider =
    NotifierProvider<
      CustomerReviewsController,
      AsyncValue<List<Map<String, dynamic>>>
    >(CustomerReviewsController.new);

class CustomerReviewsController
    extends _SessionScopedController<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> get emptyValue =>
      const <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> fetch() =>
      ref.read(customerRepositoryProvider).reviews();
}

final customerComplaintsProvider =
    NotifierProvider<
      CustomerComplaintsController,
      AsyncValue<List<Map<String, dynamic>>>
    >(CustomerComplaintsController.new);

class CustomerComplaintsController
    extends _SessionScopedController<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> get emptyValue =>
      const <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> fetch() =>
      ref.read(customerRepositoryProvider).complaints();
}

final customerConversationsProvider =
    NotifierProvider<
      CustomerConversationsController,
      AsyncValue<List<Map<String, dynamic>>>
    >(CustomerConversationsController.new);

class CustomerConversationsController
    extends _SessionScopedController<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> get emptyValue =>
      const <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> fetch() =>
      ref.read(customerRepositoryProvider).conversations();
}

/// Conversation thread detail.
///
/// Kept as a [FutureProvider] because the chat screen awaits `.future`; the
/// body still watches the account session and rejects a payload whose session
/// ended while the request was running.
final customerConversationProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, id) async {
      final session = ref.watch(sessionScopeProvider);
      if (!session.hasSession) return <String, dynamic>{};

      final data = await ref
          .watch(customerRepositoryProvider)
          .conversation(id);

      var sameSession = false;
      try {
        sameSession = ref.read(sessionScopeProvider).sameSession(session);
      } catch (_) {
        // The provider was disposed while the request was in flight; the
        // result is discarded by the container anyway.
        sameSession = false;
      }
      if (!sameSession) throw const StaleSessionException();
      return data;
    });

final customerNotificationsProvider =
    NotifierProvider<
      CustomerNotificationsController,
      AsyncValue<List<Map<String, dynamic>>>
    >(CustomerNotificationsController.new);

class CustomerNotificationsController
    extends _SessionScopedController<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> get emptyValue =>
      const <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> fetch() =>
      ref.read(customerRepositoryProvider).notifications();
}

final unreadNotificationsProvider =
    NotifierProvider<UnreadNotificationsController, AsyncValue<int>>(
      UnreadNotificationsController.new,
    );

class UnreadNotificationsController extends _SessionScopedController<int> {
  @override
  int get emptyValue => 0;

  @override
  Future<int> fetch() =>
      ref.read(customerRepositoryProvider).unreadNotificationsCount();
}

final customerCouponsProvider =
    NotifierProvider<
      CustomerCouponsController,
      AsyncValue<List<Map<String, dynamic>>>
    >(CustomerCouponsController.new);

class CustomerCouponsController
    extends _SessionScopedController<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> get emptyValue =>
      const <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> fetch() =>
      ref.read(customerRepositoryProvider).coupons();
}

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

/// `/provider/profile` nests the business record under `data.provider` and
/// keeps name/contact under a sibling `user`. Normalize both shapes (also
/// accepts a flat override used in tests) so screens read one map.
Map<String, dynamic> providerProfileFields(Map<String, dynamic>? data) {
  final root = asMap(data);
  final nested = asMap(root['provider']);
  if (nested.isEmpty) return root;
  final user = <String, dynamic>{
    ...asMap(nested['user']),
    ...asMap(root['user']),
  };
  return {...nested, if (user.isNotEmpty) 'user': user, 'provider': nested};
}

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
