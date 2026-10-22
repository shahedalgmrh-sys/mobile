import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_headers.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';

/// Extracts the `data` payload from the unified API envelope
/// `{status, message, data}` and normalizes failures.
dynamic apiData(Response response) {
  final body = response.data;
  if (body is Map<String, dynamic>) {
    if (body.containsKey('data')) return body['data'];
    return body;
  }
  return body;
}

String apiMessage(Response response, [String fallback = 'OK']) {
  final body = response.data;
  if (body is Map<String, dynamic> && body['message'] != null) {
    return body['message'].toString();
  }
  return fallback;
}

Failure failureFrom(Object error) {
  if (error is DioException) {
    final e = error.error;
    if (e is Failure) return e;
    final data = error.response?.data;
    return ServerFailure(
      code: error.response?.statusCode ?? 0,
      message: data is Map
          ? (data['message']?.toString() ?? 'Server error')
          : 'Server error',
    );
  }
  if (error is Failure) return error;
  return const ServerFailure(code: 0, message: 'Unexpected error');
}

class ApiException implements Exception {
  final Failure failure;
  const ApiException(this.failure);
  @override
  String toString() => 'ApiException($failure)';
}

/// Thin remote sources over [ApiClient]. Each method returns the unwrapped
/// `data` payload (Map or List) — parsing into models happens in repositories.
class AuthRemoteSource {
  final ApiClient client;
  const AuthRemoteSource(this.client);

  Future<Response> _run(Future<Response> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ApiException(failureFrom(e));
    }
  }

  Future<Response> login(String login, String password, String deviceName) =>
      _run(
        () => client.post(
          ApiEndpoints.login,
          data: {
            'login': login,
            'password': password,
            'device_name': deviceName,
          },
        ),
      );

  Future<Response> register(
    Map<String, dynamic> fields, {
    List<MultipartFile>? documents,
  }) => _run(
    () => client.post(
      ApiEndpoints.register,
      data: documents == null
          ? fields
          : FormData.fromMap({...fields, 'documents[]': documents}),
      options: documents == null
          ? null
          : Options(contentType: Headers.multipartFormDataContentType),
    ),
  );

  Future<Response> me() => _run(() => client.get(ApiEndpoints.authUser));
  Future<Response> logout() => _run(() => client.post(ApiEndpoints.logout));
  Future<Response> verifyOtp(String otp) =>
      _run(() => client.post(ApiEndpoints.verifyOtp, data: {'otp': otp}));
  Future<Response> resendOtp() =>
      _run(() => client.post(ApiEndpoints.resendOtp));
  Future<Response> forgotPassword(String email) => _run(
    () => client.post(ApiEndpoints.forgotPassword, data: {'email': email}),
  );
  Future<Response> resetPassword(Map<String, String> data) =>
      _run(() => client.post(ApiEndpoints.resetPassword, data: data));
}

class CatalogRemoteSource {
  final ApiClient client;
  const CatalogRemoteSource(this.client);

  Future<Response> _run(Future<Response> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ApiException(failureFrom(e));
    }
  }

  Future<Response> home() => _run(() => client.get(ApiEndpoints.home));
  Future<Response> categories() =>
      _run(() => client.get(ApiEndpoints.categories));
  Future<Response> services({
    String? q,
    String? categoryId,
    String? sort,
    int? page,
  }) => _run(
    () => client.get(
      ApiEndpoints.services,
      queryParameters: {
        if (q != null) 'q': q,
        if (categoryId != null) 'category_id': categoryId,
        if (sort != null) 'sort': sort,
        if (page != null) 'page': page,
      },
    ),
  );
  Future<Response> providers({String? cityId, int? page}) => _run(
    () => client.get(
      ApiEndpoints.providers,
      queryParameters: {
        if (cityId != null) 'city_id': cityId,
        if (page != null) 'page': page,
      },
    ),
  );
  Future<Response> providerProfile(String id) =>
      _run(() => client.get(ApiEndpoints.providerProfile(id)));
  Future<Response> offers() => _run(() => client.get(ApiEndpoints.offers));
  Future<Response> cities() => _run(() => client.get(ApiEndpoints.cities));
  Future<Response> cityAreas(String cityId) =>
      _run(() => client.get(ApiEndpoints.cityAreas(cityId)));
  Future<Response> faqs({String? category}) => _run(
    () => client.get(
      ApiEndpoints.faqs,
      queryParameters: {if (category != null) 'category': category},
    ),
  );
  Future<Response> ads() => _run(() => client.get(ApiEndpoints.ads));
  Future<Response> blogs({int? page}) => _run(
    () => client.get(
      ApiEndpoints.blogs,
      queryParameters: {if (page != null) 'page': page},
    ),
  );
  Future<Response> showBlog(String slug) =>
      _run(() => client.get(ApiEndpoints.showBlog(slug)));
  Future<Response> storeBlogComment(String blogId, String body) => _run(
    () => client.post(
      ApiEndpoints.blogComments(blogId),
      data: {'body': body},
    ),
  );
  Future<Response> page(String slug) =>
      _run(() => client.get(ApiEndpoints.contentPage(slug)));
  Future<Response> currencies() =>
      _run(() => client.get(ApiEndpoints.currencies));
  Future<Response> popularSearches() =>
      _run(() => client.get(ApiEndpoints.searchPopular));
  Future<Response> contact(Map<String, dynamic> data) =>
      _run(() => client.post(ApiEndpoints.contact, data: data));
}

class CustomerRemoteSource {
  final ApiClient client;
  const CustomerRemoteSource(this.client);

  Future<Response> _run(Future<Response> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ApiException(failureFrom(e));
    }
  }

  // Profile
  Future<Response> me() => _run(() => client.get(ApiEndpoints.customerMe));
  Future<Response> updateMe(Map<String, dynamic> data) =>
      _run(() => client.put(ApiEndpoints.customerMe, data: data));
  Future<Response> updateAvatar(MultipartFile image) => _run(
    () => client.post(
      ApiEndpoints.customerAvatar,
      data: FormData.fromMap({'avatar': image}),
      options: Options(contentType: Headers.multipartFormDataContentType),
    ),
  );
  Future<Response> deleteAvatar() =>
      _run(() => client.delete(ApiEndpoints.customerAvatar));
  Future<Response> changePassword(
    String current,
    String password,
    String confirmation,
  ) => _run(
    () => client.post(
      ApiEndpoints.customerPassword,
      data: {
        'current_password': current,
        'password': password,
        'password_confirmation': confirmation,
      },
    ),
  );
  Future<Response> updatePreferences(Map<String, dynamic> data) =>
      _run(() => client.post(ApiEndpoints.customerPreferences, data: data));
  Future<Response> destroyAccount(String password) => _run(
    () => client.delete(ApiEndpoints.customerMe, data: {'password': password}),
  );

  // Addresses
  Future<Response> addresses() =>
      _run(() => client.get(ApiEndpoints.customerAddresses));
  Future<Response> storeAddress(Map<String, dynamic> data) =>
      _run(() => client.post(ApiEndpoints.customerAddresses, data: data));
  Future<Response> updateAddress(String id, Map<String, dynamic> data) =>
      _run(() => client.put(ApiEndpoints.customerAddress(id), data: data));
  Future<Response> destroyAddress(String id) =>
      _run(() => client.delete(ApiEndpoints.customerAddress(id)));

  // Bookings
  Future<Response> bookings({String? status, int? page}) => _run(
    () => client.get(
      ApiEndpoints.customerBookings,
      queryParameters: {
        if (status != null) 'status': status,
        if (page != null) 'page': page,
      },
    ),
  );
  Future<Response> createBooking(
    Map<String, dynamic> data, {
    String? idempotencyKey,
  }) => _run(
    () => client.post(
      ApiEndpoints.customerBookings,
      data: {
        ...data,
        if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      },
      options: idempotencyKey == null
          ? null
          : Options(headers: {AppHeaders.xIdempotencyKey: idempotencyKey}),
    ),
  );
  Future<Response> availableSlots({
    String? serviceId,
    String? service,
    required String date,
  }) => _run(
    () => client.get(
      ApiEndpoints.bookingAvailableSlots,
      queryParameters: {
        if (serviceId != null) 'service_id': serviceId,
        if (service != null) 'service': service,
        'date': date,
      },
    ),
  );
  Future<Response> showBooking(String id) =>
      _run(() => client.get(ApiEndpoints.customerBooking(id)));
  Future<Response> trackBooking(String id) =>
      _run(() => client.get(ApiEndpoints.bookingTrack(id)));
  Future<Response> cancelBooking(String id, String reason) => _run(
    () => client.post(ApiEndpoints.bookingCancel(id), data: {'reason': reason}),
  );
  Future<Response> rescheduleBooking(
    String id,
    String date,
    String time, {
    String? reason,
  }) => _run(
    () => client.post(
      ApiEndpoints.bookingReschedule(id),
      data: {
        'booking_date': date,
        'booking_time': time,
        if (reason != null) 'reason': reason,
      },
    ),
  );
  Future<Response> rebook(String id) =>
      _run(() => client.post(ApiEndpoints.bookingRebook(id)));
  Future<Response> payBooking(String id, String method) => _run(
    () => client.post(
      ApiEndpoints.bookingPay(id),
      data: {'payment_method': method},
    ),
  );

  // Payments
  Future<Response> payments({String? page}) => _run(
    () => client.get(
      ApiEndpoints.customerPayments,
      queryParameters: {if (page != null) 'page': page},
    ),
  );
  Future<Response> invoice(String paymentId) =>
      _run(() => client.get(ApiEndpoints.paymentInvoice(paymentId)));
  Future<Response> payment(String paymentId) =>
      _run(() => client.get(ApiEndpoints.payment(paymentId)));

  // Wallet
  Future<Response> wallet() =>
      _run(() => client.get(ApiEndpoints.customerWallet));
  Future<Response> walletTransactions({String? page}) => _run(
    () => client.get(
      ApiEndpoints.walletTransactions,
      queryParameters: {if (page != null) 'page': page},
    ),
  );
  Future<Response> addFunds(double amount, String method) => _run(
    () => client.post(
      ApiEndpoints.walletAddFunds,
      data: {'amount': amount, 'payment_method': method},
    ),
  );
  Future<Response> confirmWalletPayment(String paymentId) =>
      _run(() => client.post(ApiEndpoints.walletConfirmPayment(paymentId)));

  // Favorites
  Future<Response> favorites() =>
      _run(() => client.get(ApiEndpoints.customerFavorites));
  Future<Response> toggleServiceFavorite(String serviceId) => _run(
    () => client.post(
      ApiEndpoints.favoriteToggle,
      data: {'service_id': serviceId},
    ),
  );
  Future<Response> toggleProviderFavorite(String providerId) =>
      _run(() => client.post(ApiEndpoints.favoriteProviderToggle(providerId)));

  // Reviews & complaints
  Future<Response> reviews() =>
      _run(() => client.get(ApiEndpoints.customerReviews));
  Future<Response> storeReview(Map<String, dynamic> data) =>
      _run(() => client.post(ApiEndpoints.customerReviews, data: data));
  Future<Response> complaints() =>
      _run(() => client.get(ApiEndpoints.customerComplaints));
  Future<Response> storeComplaint(Map<String, dynamic> data) =>
      _run(() => client.post(ApiEndpoints.customerComplaints, data: data));

  // Chat
  Future<Response> conversations() =>
      _run(() => client.get(ApiEndpoints.customerConversations));
  Future<Response> conversation(String id) =>
      _run(() => client.get(ApiEndpoints.conversation(id)));
  Future<Response> sendMessage(
    String id,
    String body, {
    List<MultipartFile>? attachments,
  }) => _run(
    () => client.post(
      ApiEndpoints.conversationMessages(id),
      data: attachments == null
          ? {'body': body}
          : FormData.fromMap({'body': body, 'attachments[]': attachments}),
      options: attachments == null
          ? null
          : Options(contentType: Headers.multipartFormDataContentType),
    ),
  );

  // Notifications
  Future<Response> notifications({String? page}) => _run(
    () => client.get(
      ApiEndpoints.customerNotifications,
      queryParameters: {if (page != null) 'page': page},
    ),
  );
  Future<Response> unreadNotifications() =>
      _run(() => client.get(ApiEndpoints.notificationsUnread));
  Future<Response> markNotificationRead(String id) =>
      _run(() => client.post(ApiEndpoints.notificationRead(id)));

  // Coupons & search
  Future<Response> coupons() =>
      _run(() => client.get(ApiEndpoints.customerCoupons));
  Future<Response> validateCoupon(
    String code, {
    required double subtotal,
    String? serviceId,
  }) => _run(
    () => client.post(
      ApiEndpoints.couponValidate,
      data: {
        'code': code,
        'subtotal': subtotal,
        if (serviceId != null) 'service_id': serviceId,
      },
    ),
  );
  Future<Response> search(
    String q, {
    Map<String, dynamic>? filters,
    int? page,
  }) => _run(
    () => client.get(
      ApiEndpoints.customerSearch,
      queryParameters: {'q': q, if (page != null) 'page': page, ...?filters},
    ),
  );
  Future<Response> reports(String type) =>
      _run(() => client.get(ApiEndpoints.customerReport(type)));
}

class ProviderRemoteSource {
  final ApiClient client;
  const ProviderRemoteSource(this.client);

  Future<Response> _run(Future<Response> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ApiException(failureFrom(e));
    }
  }

  Future<Response> dashboard() =>
      _run(() => client.get(ApiEndpoints.providerDashboard));
  Future<Response> profile() =>
      _run(() => client.get(ApiEndpoints.providerProfileMe));
  Future<Response> updateProfile(Map<String, dynamic> data) =>
      _run(() => client.put(ApiEndpoints.providerProfileMe, data: data));
  Future<Response> updateProviderLogo(MultipartFile image) => _run(
    () => client.post(
      ApiEndpoints.providerLogo,
      data: FormData.fromMap({'logo': image}),
      options: Options(contentType: Headers.multipartFormDataContentType),
    ),
  );
  Future<Response> deleteProviderImage(String kind) => _run(() => client
      .delete(switch (kind) {
        'avatar' => ApiEndpoints.providerAvatarDestroy,
        'logo' => ApiEndpoints.providerLogoDestroy,
        _ => ApiEndpoints.providerCoverDestroy,
      }));
  Future<Response> changePassword(
    String current,
    String password,
    String confirmation,
  ) => _run(
    () => client.post(
      ApiEndpoints.providerPassword,
      data: {
        'current_password': current,
        'password': password,
        'password_confirmation': confirmation,
      },
    ),
  );
  Future<Response> verificationStatus() =>
      _run(() => client.get(ApiEndpoints.providerVerificationStatus));
  Future<Response> submitVerification(
    Map<String, dynamic> fields, {
    List<MultipartFile>? documents,
  }) => _run(
    () => client.post(
      ApiEndpoints.providerVerification,
      data: documents == null
          ? fields
          : FormData.fromMap({...fields, 'documents[]': documents}),
      options: documents == null
          ? null
          : Options(contentType: Headers.multipartFormDataContentType),
    ),
  );

  // Services
  Future<Response> services() =>
      _run(() => client.get(ApiEndpoints.providerServices));
  Future<Response> showService(String id) =>
      _run(() => client.get(ApiEndpoints.providerService(id)));
  Future<Response> storeService(
    Map<String, dynamic> data, {
    List<MultipartFile>? images,
  }) => _run(
    () => client.post(
      ApiEndpoints.providerServices,
      data: images == null || images.isEmpty
          ? data
          : FormData.fromMap({...data, 'images[]': images}),
      options: images == null || images.isEmpty
          ? null
          : Options(contentType: Headers.multipartFormDataContentType),
    ),
  );
  Future<Response> updateService(String id, Map<String, dynamic> data) =>
      _run(() => client.put(ApiEndpoints.providerService(id), data: data));
  Future<Response> destroyService(String id) =>
      _run(() => client.delete(ApiEndpoints.providerService(id)));
  Future<Response> toggleService(String id) =>
      _run(() => client.post(ApiEndpoints.serviceToggleActive(id)));
  Future<Response> duplicateService(String id) =>
      _run(() => client.post(ApiEndpoints.serviceDuplicate(id)));

  // Bookings
  Future<Response> bookings({String? status, String? date, int? page}) => _run(
    () => client.get(
      ApiEndpoints.providerBookings,
      queryParameters: {
        if (status != null) 'status': status,
        if (date != null) 'date': date,
        if (page != null) 'page': page,
      },
    ),
  );
  Future<Response> showBooking(String id) =>
      _run(() => client.get(ApiEndpoints.providerBooking(id)));
  Future<Response> acceptBooking(String id) =>
      _run(() => client.post(ApiEndpoints.bookingAccept(id)));
  Future<Response> rejectBooking(String id, {String? reason}) => _run(
    () => client.post(
      ApiEndpoints.bookingReject(id),
      data: {if (reason != null) 'reason': reason},
    ),
  );
  Future<Response> startBooking(String id) =>
      _run(() => client.post(ApiEndpoints.bookingStart(id)));
  Future<Response> completeBooking(String id) =>
      _run(() => client.post(ApiEndpoints.bookingComplete(id)));
  Future<Response> cancelBooking(String id, {required String reason}) => _run(
    () => client.post(
      ApiEndpoints.providerBookingCancel(id),
      data: {'reason': reason},
    ),
  );
  Future<Response> rescheduleBooking(
    String id,
    String date,
    String time, {
    String? reason,
  }) => _run(
    () => client.post(
      ApiEndpoints.providerBookingReschedule(id),
      data: {
        'booking_date': date,
        'booking_time': time,
        if (reason != null) 'reason': reason,
      },
    ),
  );

  // Availability
  Future<Response> availability() =>
      _run(() => client.get(ApiEndpoints.providerAvailability));
  Future<Response> storeWorkingHour(Map<String, dynamic> data) =>
      _run(() => client.post(ApiEndpoints.workingHours, data: data));
  Future<Response> destroyWorkingHour(String id) =>
      _run(() => client.delete(ApiEndpoints.workingHour(id)));
  Future<Response> storeArea(Map<String, dynamic> data) =>
      _run(() => client.post(ApiEndpoints.availabilityAreas, data: data));
  Future<Response> destroyArea(String id) =>
      _run(() => client.delete(ApiEndpoints.availabilityArea(id)));

  // Portfolio
  Future<Response> portfolio() =>
      _run(() => client.get(ApiEndpoints.providerPortfolio));
  Future<Response> storePortfolio(
    Map<String, dynamic> fields, {
    MultipartFile? image,
  }) => _run(
    () => client.post(
      ApiEndpoints.providerPortfolio,
      data: image == null
          ? fields
          : FormData.fromMap({...fields, 'image': image}),
      options: image == null
          ? null
          : Options(contentType: Headers.multipartFormDataContentType),
    ),
  );
  Future<Response> destroyPortfolio(String id) =>
      _run(() => client.delete(ApiEndpoints.portfolioItem(id)));

  // Wallet & withdrawals
  Future<Response> wallet() =>
      _run(() => client.get(ApiEndpoints.providerWallet));
  Future<Response> withdrawals() =>
      _run(() => client.get(ApiEndpoints.providerWithdrawals));
  Future<Response> storeWithdrawal(Map<String, dynamic> data) =>
      _run(() => client.post(ApiEndpoints.providerWithdrawals, data: data));
  Future<Response> cancelWithdrawal(String id) =>
      _run(() => client.post(ApiEndpoints.withdrawalCancel(id)));

  // Reviews
  Future<Response> reviews() =>
      _run(() => client.get(ApiEndpoints.providerReviews));
  Future<Response> replyReview(String id, String reply) => _run(
    () => client.post(ApiEndpoints.reviewReply(id), data: {'reply': reply}),
  );

  // Chat
  Future<Response> conversations() =>
      _run(() => client.get(ApiEndpoints.providerConversations));
  Future<Response> conversation(String id) =>
      _run(() => client.get(ApiEndpoints.providerConversation(id)));
  Future<Response> sendMessage(
    String id,
    String body, {
    List<MultipartFile>? attachments,
  }) => _run(
    () => client.post(
      ApiEndpoints.providerConversationMessages(id),
      data: attachments == null
          ? {'body': body}
          : FormData.fromMap({'body': body, 'attachments[]': attachments}),
      options: attachments == null
          ? null
          : Options(contentType: Headers.multipartFormDataContentType),
    ),
  );

  // Notifications
  Future<Response> notifications({String? page}) => _run(
    () => client.get(
      ApiEndpoints.providerNotifications,
      queryParameters: {if (page != null) 'page': page},
    ),
  );
  Future<Response> markNotificationRead(String id) =>
      _run(() => client.post(ApiEndpoints.providerNotificationRead(id)));
  Future<Response> markAllNotificationsRead() =>
      _run(() => client.post(ApiEndpoints.providerNotificationsReadAll));

  // B2B requests
  Future<Response> serviceRequests({String? type}) => _run(
    () => client.get(
      ApiEndpoints.providerRequests,
      queryParameters: {if (type != null) 'type': type},
    ),
  );
  Future<Response> storeServiceRequest(Map<String, dynamic> data) =>
      _run(() => client.post(ApiEndpoints.providerRequests, data: data));
  Future<Response> acceptServiceRequest(String id) =>
      _run(() => client.post(ApiEndpoints.requestAccept(id)));
  Future<Response> rejectServiceRequest(String id, {String? reason}) => _run(
    () => client.post(
      ApiEndpoints.requestReject(id),
      data: {if (reason != null) 'reason': reason},
    ),
  );
  Future<Response> completeServiceRequest(String id) =>
      _run(() => client.post(ApiEndpoints.requestComplete(id)));

  // Reports
  Future<Response> bookingsReport({String? from, String? to}) => _run(
    () => client.get(
      ApiEndpoints.reportBookings,
      queryParameters: {
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      },
    ),
  );
  Future<Response> revenueReport({String? from, String? to}) => _run(
    () => client.get(
      ApiEndpoints.reportRevenue,
      queryParameters: {
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      },
    ),
  );
}
