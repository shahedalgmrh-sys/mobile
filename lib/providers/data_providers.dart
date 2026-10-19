import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../data/repositories/catalog_repository.dart';

// ---------------------------------------------------------------------------
// Public catalog
// ---------------------------------------------------------------------------

final homeFeedProvider = FutureProvider<HomeFeed>(
  (ref) => ref.watch(catalogRepositoryProvider).home(),
);

final categoriesProvider = FutureProvider<List<CategoryItem>>(
  (ref) => ref.watch(catalogRepositoryProvider).categories(),
);

final servicesProvider = FutureProvider.autoDispose
    .family<List<dynamic>, ({String? q, String? categoryId, String? sort})>(
  (ref, params) => ref
      .watch(catalogRepositoryProvider)
      .services(q: params.q, categoryId: params.categoryId, sort: params.sort),
);

final providersCatalogProvider = FutureProvider.autoDispose
    .family<List<dynamic>, ({String? cityId, int? page})>(
  (ref, params) => ref
      .watch(catalogRepositoryProvider)
      .providers(cityId: params.cityId, page: params.page),
);

final publicProviderProfileProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
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
  (ref, status) => ref.watch(customerRepositoryProvider).bookings(status: status),
);

final customerBookingProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(customerRepositoryProvider).booking(id),
);

final bookingTrackProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
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

final customerConversationsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(customerRepositoryProvider).conversations(),
);

final customerConversationProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
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

final providerBookingProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
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

final providerConversationsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(providerRepositoryProvider).conversations(),
);

final providerConversationProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
  (ref, id) => ref.watch(providerRepositoryProvider).conversation(id),
);

final providerNotificationsProvider =
    FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(providerRepositoryProvider).notifications(),
);

final serviceRequestsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String?>(
  (ref, type) => ref.watch(providerRepositoryProvider).serviceRequests(type: type),
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
