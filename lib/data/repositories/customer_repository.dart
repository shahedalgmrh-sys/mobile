import '../sources/remote_sources.dart';
import 'parsers.dart';

/// Customer-side repository — returns decoded API payloads (Maps/Lists)
/// normalized via [parsers]. Screens/providers consume these directly.
class CustomerRepository {
  final CustomerRemoteSource source;
  const CustomerRepository(this.source);

  Future<Map<String, dynamic>> me() async =>
      asMap(apiData(await source.me()));

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> data) async =>
      asMap(apiData(await source.updateMe(data)));

  Future<void> changePassword(
          String current, String password, String confirmation) async =>
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

  Future<Map<String, dynamic>> updateAddress(int id, Map<String, dynamic> data) async =>
      asMap(apiData(await source.updateAddress(id, data)));

  Future<void> destroyAddress(int id) => source.destroyAddress(id);

  // Bookings
  Future<List<Map<String, dynamic>>> bookings({String? status, int? page}) async =>
      dataList(apiData(await source.bookings(status: status, page: page)));

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> data) async =>
      asMap(apiData(await source.createBooking(data)));

  Future<Map<String, dynamic>> booking(int id) async =>
      asMap(apiData(await source.showBooking(id)));

  Future<Map<String, dynamic>> trackBooking(int id) async =>
      asMap(apiData(await source.trackBooking(id)));

  Future<Map<String, dynamic>> cancelBooking(int id, String reason) async =>
      asMap(apiData(await source.cancelBooking(id, reason)));

  Future<Map<String, dynamic>> rescheduleBooking(int id, String date, String time,
          {String? reason}) async =>
      asMap(apiData(await source.rescheduleBooking(id, date, time, reason: reason)));

  Future<Map<String, dynamic>> rebook(int id) async =>
      asMap(apiData(await source.rebook(id)));

  Future<Map<String, dynamic>> payBooking(int id, String method) async =>
      asMap(apiData(await source.payBooking(id, method)));

  // Payments
  Future<List<Map<String, dynamic>>> payments({int? page}) async =>
      dataList(apiData(await source.payments(page: page)));

  Future<Map<String, dynamic>> invoice(int paymentId) async =>
      asMap(apiData(await source.invoice(paymentId)));

  // Wallet
  Future<Map<String, dynamic>> wallet() async =>
      asMap(apiData(await source.wallet()));

  Future<List<Map<String, dynamic>>> walletTransactions({int? page}) async =>
      dataList(apiData(await source.walletTransactions(page: page)));

  Future<Map<String, dynamic>> addFunds(double amount, String method) async =>
      asMap(apiData(await source.addFunds(amount, method)));

  // Favorites
  Future<Map<String, dynamic>> favorites() async =>
      asMap(apiData(await source.favorites()));

  Future<void> toggleServiceFavorite(int serviceId) =>
      source.toggleServiceFavorite(serviceId);

  Future<void> toggleProviderFavorite(int providerId) =>
      source.toggleProviderFavorite(providerId);

  // Reviews & complaints
  Future<List<Map<String, dynamic>>> reviews() async =>
      dataList(apiData(await source.reviews()));

  Future<Map<String, dynamic>> storeReview({
    required int bookingId,
    required int rating,
    String? comment,
  }) async =>
      asMap(apiData(await source.storeReview({
            'booking_id': bookingId,
            'rating': rating,
            if (comment != null) 'comment': comment,
          })));

  Future<List<Map<String, dynamic>>> complaints() async =>
      dataList(apiData(await source.complaints()));

  Future<Map<String, dynamic>> storeComplaint({
    int? bookingId,
    required String subject,
    required String description,
    String priority = 'medium',
  }) async =>
      asMap(apiData(await source.storeComplaint({
            if (bookingId != null) 'booking_id': bookingId,
            'subject': subject,
            'description': description,
            'priority': priority,
          })));

  // Chat
  Future<List<Map<String, dynamic>>> conversations() async =>
      dataList(apiData(await source.conversations()));

  Future<Map<String, dynamic>> conversation(int id) async =>
      asMap(apiData(await source.conversation(id)));

  Future<Map<String, dynamic>> sendMessage(int id, String body) async =>
      asMap(apiData(await source.sendMessage(id, body)));

  // Notifications
  Future<List<Map<String, dynamic>>> notifications({int? page}) async =>
      dataList(apiData(await source.notifications(page: page)));

  Future<List<Map<String, dynamic>>> unreadNotifications() async =>
      dataList(apiData(await source.unreadNotifications()));

  Future<void> markNotificationRead(String id) => source.markNotificationRead(id);

  // Coupons & search
  Future<List<Map<String, dynamic>>> coupons() async =>
      dataList(apiData(await source.coupons()));

  Future<Map<String, dynamic>> validateCoupon(String code,
          {required double subtotal, int? serviceId}) async =>
      asMap(apiData(await source.validateCoupon(code,
          subtotal: subtotal, serviceId: serviceId)));

  Future<Map<String, dynamic>> search(String q, {Map<String, dynamic>? filters}) async =>
      asMap(apiData(await source.search(q, filters: filters)));
}
