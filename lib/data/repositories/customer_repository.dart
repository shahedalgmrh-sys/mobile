import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../sources/remote_sources.dart';
import 'parsers.dart';

/// Customer-side repository — returns decoded API payloads (Maps/Lists)
/// normalized via [parsers]. Screens/providers consume these directly.
class CustomerRepository {
  final CustomerRemoteSource source;
  static const Uuid _uuid = Uuid();
  const CustomerRepository(this.source);

  Future<Map<String, dynamic>> me() async => asMap(apiData(await source.me()));

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> data) async =>
      asMap(apiData(await source.updateMe(data)));

  Future<Map<String, dynamic>> updateAvatar(String filePath) async {
    final file = await MultipartFile.fromFile(
      filePath,
      filename: filePath.split(RegExp(r'[\\/]')).last,
    );
    return asMap(apiData(await source.updateAvatar(file)));
  }

  Future<void> deleteAvatar() async => apiData(await source.deleteAvatar());

  Future<void> changePassword(
    String current,
    String password,
    String confirmation,
  ) async =>
      apiData(await source.changePassword(current, password, confirmation));

  Future<void> updatePreferences(Map<String, dynamic> data) async =>
      apiData(await source.updatePreferences(data));

  Future<void> destroyAccount(String password) async =>
      apiData(await source.destroyAccount(password));

  // Addresses
  Future<List<Map<String, dynamic>>> addresses() async =>
      dataList(apiData(await source.addresses()));

  Future<Map<String, dynamic>> storeAddress(Map<String, dynamic> data) async =>
      asMap(apiData(await source.storeAddress(data)));

  Future<Map<String, dynamic>> updateAddress(
    String id,
    Map<String, dynamic> data,
  ) async => asMap(apiData(await source.updateAddress(id, data)));

  Future<void> destroyAddress(String id) => source.destroyAddress(id);

  // Bookings
  Future<List<Map<String, dynamic>>> bookings({
    String? status,
    int? page,
  }) async =>
      dataList(apiData(await source.bookings(status: status, page: page)));

  /// Full envelope for bookings: `data` holds the rows while the paginator
  /// `meta` is a sibling at the top level (unlike `/customer/reports/{type}`,
  /// which nests the whole paginator under `data`). Returning the envelope
  /// keeps both, so callers can paginate and show the real total.
  Future<Map<String, dynamic>> bookingsPage({String? status, int? page}) async {
    final response = await source.bookings(status: status, page: page);
    final body = response.data;
    return body is Map<String, dynamic> ? body : <String, dynamic>{};
  }

  /// Creates a booking. A fresh UUIDv4 idempotency key is attached on every
  /// client-initiated call so a retried submit cannot create duplicates
  /// (server honors `X-Idempotency-Key` / `idempotency_key`).
  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> data) async =>
      asMap(
        apiData(await source.createBooking(data, idempotencyKey: _uuid.v4())),
      );

  /// Time slots available for a given service on a specific date.
  /// Server shape: `data: {date, service_id, slots: [...]}` — the inner
  /// `slots` list must be unwrapped explicitly, otherwise every day parses
  /// as unavailable.
  Future<List<Map<String, dynamic>>> availableSlots({
    String? serviceId,
    String? service,
    required String date,
  }) async {
    final d = asMap(
      apiData(
        await source.availableSlots(
          serviceId: serviceId,
          service: service,
          date: date,
        ),
      ),
    );
    return dataList(d['slots'] ?? d['available_slots'] ?? d);
  }

  Future<Map<String, dynamic>> booking(String id) async =>
      asMap(apiData(await source.showBooking(id)));

  Future<Map<String, dynamic>> trackBooking(String id) async =>
      asMap(apiData(await source.trackBooking(id)));

  Future<Map<String, dynamic>> cancelBooking(String id, String reason) async =>
      asMap(apiData(await source.cancelBooking(id, reason)));

  Future<Map<String, dynamic>> rescheduleBooking(
    String id,
    String date,
    String time, {
    String? reason,
  }) async => asMap(
    apiData(await source.rescheduleBooking(id, date, time, reason: reason)),
  );

  Future<Map<String, dynamic>> rebook(String id) async =>
      asMap(apiData(await source.rebook(id)));

  Future<Map<String, dynamic>> payBooking(String id, String method) async =>
      asMap(apiData(await source.payBooking(id, method)));

  // Payments
  Future<List<Map<String, dynamic>>> payments({String? page}) async =>
      dataList(apiData(await source.payments(page: page)));

  Future<Map<String, dynamic>> invoice(String paymentId) async =>
      asMap(apiData(await source.invoice(paymentId)));

  Future<Map<String, dynamic>> payment(String paymentId) async =>
      asMap(apiData(await source.payment(paymentId)));

  // Wallet
  Future<Map<String, dynamic>> wallet() async =>
      asMap(apiData(await source.wallet()));

  Future<List<Map<String, dynamic>>> walletTransactions({String? page}) async =>
      dataList(apiData(await source.walletTransactions(page: page)));

  Future<Map<String, dynamic>> addFunds(double amount, String method) async =>
      asMap(apiData(await source.addFunds(amount, method)));

  Future<Map<String, dynamic>> confirmWalletPayment(String paymentId) async =>
      asMap(apiData(await source.confirmWalletPayment(paymentId)));

  // Favorites
  Future<Map<String, dynamic>> favorites() async =>
      asMap(apiData(await source.favorites()));

  Future<bool> toggleServiceFavorite(String serviceId) async {
    final response = await source.toggleServiceFavorite(serviceId);
    return _favoritedFrom(response);
  }

  Future<bool> toggleProviderFavorite(String providerId) async {
    final response = await source.toggleProviderFavorite(providerId);
    return _favoritedFrom(response);
  }

  /// The toggle endpoints answer `{status, favorited, message}` at the top
  /// level (no `data` envelope), so the boolean must be read from the raw
  /// response. A successful response without a boolean is a protocol error:
  /// never infer the new state by flipping the previous one.
  static bool _favoritedFrom(Response response) {
    final body = response.data;
    final value = body is Map ? body['favorited'] : null;
    if (value is bool) return value;
    throw const InvalidFavoriteResponseException();
  }

  // Reviews & complaints
  Future<List<Map<String, dynamic>>> reviews() async =>
      dataList(apiData(await source.reviews()));

  Future<Map<String, dynamic>> storeReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async => asMap(
    apiData(
      await source.storeReview({
        'booking_id': bookingId,
        'rating': rating,
        if (comment != null) 'comment': comment,
      }),
    ),
  );

  Future<List<Map<String, dynamic>>> complaints() async =>
      dataList(apiData(await source.complaints()));

  Future<Map<String, dynamic>> storeComplaint({
    String? bookingId,
    required String subject,
    required String description,
    String priority = 'medium',
  }) async => asMap(
    apiData(
      await source.storeComplaint({
        if (bookingId != null) 'booking_id': bookingId,
        'subject': subject,
        'description': description,
        'priority': priority,
      }),
    ),
  );

  // Chat
  Future<List<Map<String, dynamic>>> conversations() async {
    final payload = apiData(await source.conversations());
    final map = asMap(payload);
    return dataList(map['conversations'] ?? map['items'] ?? payload);
  }

  Future<Map<String, dynamic>> conversation(String id) async {
    final payload = apiData(await source.conversation(id));
    final map = asMap(payload);
    final conversation = asMap(map['conversation'] ?? map['thread'] ?? payload);
    // The API returns `{conversation: {...}, messages: [...]}`. Keep the
    // sibling message list instead of discarding it, otherwise the thread
    // always renders as empty.
    final messages = dataList(
      map['messages'] ?? conversation['messages'] ?? map['chat_messages'],
    );
    return {...conversation, 'messages': messages};
  }

  Future<Map<String, dynamic>> sendMessage(String id, String body) async =>
      asMap(apiData(await source.sendMessage(id, body)));

  // Notifications
  Future<List<Map<String, dynamic>>> notifications({String? page}) async =>
      dataList(apiData(await source.notifications(page: page)));

  /// `/customer/notifications/unread` returns a top-level `unread_count`,
  /// not a list. Parse it directly so the home badge reflects real data.
  Future<int> unreadNotificationsCount() async {
    final body = (await source.unreadNotifications()).data;
    return body is Map ? toInt(body['unread_count']) : 0;
  }

  Future<void> markNotificationRead(String id) =>
      source.markNotificationRead(id);

  // Coupons & search
  Future<List<Map<String, dynamic>>> coupons() async =>
      dataList(apiData(await source.coupons()));

  Future<Map<String, dynamic>> validateCoupon(
    String code, {
    required double subtotal,
    String? serviceId,
  }) async => asMap(
    apiData(
      await source.validateCoupon(
        code,
        subtotal: subtotal,
        serviceId: serviceId,
      ),
    ),
  );

  Future<SearchPage> search(
    String q, {
    Map<String, dynamic>? filters,
    int? page,
  }) async {
    // Read the raw envelope here: `apiData` unwraps `data` and would drop the
    // sibling `meta` block that drives pagination.
    final response = await source.search(q, filters: filters, page: page);
    final envelope = asMap(response.data);
    final items = dataList(
      envelope.containsKey('data') ? envelope['data'] : response.data,
    );
    final meta = asMap(envelope['meta']);
    final current = toInt(meta['current_page'], page ?? 1);
    return SearchPage(
      items: items,
      currentPage: current,
      lastPage: toInt(meta['last_page'], current),
      total: toInt(meta['total'], items.length),
    );
  }

  Future<Map<String, dynamic>> reports(String type, {String? page}) async =>
      asMap(apiData(await source.reports(type, page: page)));
}

/// Thrown when a favorite toggle reports success without the boolean
/// `favorited` flag, so callers never guess the resulting state.
class InvalidFavoriteResponseException implements Exception {
  const InvalidFavoriteResponseException();

  @override
  String toString() => 'InvalidFavoriteResponseException';
}

/// One page of `/customer/search` results plus the API's pagination metadata.
class SearchPage {
  const SearchPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<Map<String, dynamic>> items;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasMore => currentPage < lastPage;
}
