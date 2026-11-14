import 'package:dio/dio.dart';

import '../sources/remote_sources.dart';
import 'parsers.dart';

/// Provider-side repository — decoded API payloads for the provider app.
class ProviderRepository {
  final ProviderRemoteSource source;
  const ProviderRepository(this.source);

  Future<Map<String, dynamic>> dashboard() async =>
      asMap(apiData(await source.dashboard()));

  /// `/provider/profile` responds `{data: {provider: {...}, user: {...}}}`.
  /// Flatten it (while keeping both keys) so callers can read
  /// `business_name`, `is_verified`, and `id` directly.
  Future<Map<String, dynamic>> profile() async {
    final payload = asMap(apiData(await source.profile()));
    final provider = asMap(payload['provider']);
    if (provider.isEmpty) return payload;
    final user = <String, dynamic>{
      ...asMap(provider['user']),
      ...asMap(payload['user']),
    };
    return {
      ...provider,
      if (user.isNotEmpty) 'user': user,
      'provider': provider,
    };
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async =>
      asMap(apiData(await source.updateProfile(data)));

  /// Uploads the business logo (multipart `logo`, jpeg/png ≤4MB per server).
  Future<Map<String, dynamic>> updateLogo(String filePath) async {
    final file = await MultipartFile.fromFile(
      filePath,
      filename: filePath.split(RegExp(r'[\\/]')).last,
    );
    return asMap(apiData(await source.updateProviderLogo(file)));
  }

  /// Deletes a profile image by kind: `avatar` | `logo` | `cover`.
  Future<void> deleteProviderImage(String kind) =>
      source.deleteProviderImage(kind);

  Future<void> changePassword(
    String current,
    String password,
    String confirmation,
  ) async =>
      apiData(await source.changePassword(current, password, confirmation));

  Future<Map<String, dynamic>> verificationStatus() async =>
      asMap(apiData(await source.verificationStatus()));

  Future<void> submitVerification({
    List<String> filePaths = const [],
    String? notes,
  }) async {
    final docs = <MultipartFile>[
      for (final p in filePaths)
        await MultipartFile.fromFile(
          p,
          filename: p.split(RegExp(r'[\\/]')).last,
        ),
    ];
    await apiData(
      await source.submitVerification({
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      }, documents: docs.isEmpty ? null : docs),
    );
  }

  // Services
  Future<List<Map<String, dynamic>>> services() async =>
      dataList(apiData(await source.services()));

  Future<Map<String, dynamic>> service(String id) async =>
      asMap(apiData(await source.showService(id)));

  Future<Map<String, dynamic>> storeService(
    Map<String, dynamic> data, {
    List<MultipartFile> images = const [],
  }) async => asMap(apiData(await source.storeService(data, images: images)));

  Future<Map<String, dynamic>> updateService(
    String id,
    Map<String, dynamic> data,
  ) async => asMap(apiData(await source.updateService(id, data)));

  Future<void> destroyService(String id) => source.destroyService(id);

  Future<Map<String, dynamic>> toggleService(String id) async =>
      asMap(apiData(await source.toggleService(id)));

  /// Independent from activation: pauses/resumes new bookings only.
  Future<Map<String, dynamic>> toggleServiceAvailable(String id) async =>
      asMap(apiData(await source.toggleServiceAvailable(id)));

  Future<Map<String, dynamic>> duplicateService(String id) async =>
      asMap(apiData(await source.duplicateService(id)));

  // Bookings
  Future<List<Map<String, dynamic>>> bookings({
    String? status,
    String? date,
    int? page,
  }) async => dataList(
    apiData(await source.bookings(status: status, date: date, page: page)),
  );

  Future<Map<String, dynamic>> booking(String id) async =>
      asMap(apiData(await source.showBooking(id)));

  Future<Map<String, dynamic>> acceptBooking(String id) async =>
      asMap(apiData(await source.acceptBooking(id)));

  Future<Map<String, dynamic>> rejectBooking(
    String id, {
    String? reason,
  }) async => asMap(apiData(await source.rejectBooking(id, reason: reason)));

  Future<Map<String, dynamic>> startBooking(String id) async =>
      asMap(apiData(await source.startBooking(id)));

  Future<Map<String, dynamic>> completeBooking(String id) async =>
      asMap(apiData(await source.completeBooking(id)));

  Future<Map<String, dynamic>> cancelBooking(String id, String reason) async =>
      asMap(apiData(await source.cancelBooking(id, reason: reason)));

  Future<Map<String, dynamic>> rescheduleBooking(
    String id,
    String date,
    String time, {
    String? reason,
  }) async => asMap(
    apiData(await source.rescheduleBooking(id, date, time, reason: reason)),
  );

  // Availability
  Future<Map<String, dynamic>> availability() async =>
      asMap(apiData(await source.availability()));

  Future<void> storeWorkingHour(Map<String, dynamic> data) =>
      source.storeWorkingHour(data);

  Future<void> destroyWorkingHour(String id) => source.destroyWorkingHour(id);

  Future<void> storeArea(Map<String, dynamic> data) => source.storeArea(data);

  Future<void> destroyArea(String id) => source.destroyArea(id);

  // Portfolio
  Future<List<Map<String, dynamic>>> portfolio() async =>
      dataList(apiData(await source.portfolio()));

  Future<Map<String, dynamic>> storePortfolio({
    required String title,
    String? description,
    String? category,
    String? completionDate,
    String? clientName,
    String? location,
    num? budget,
    bool? isFeatured,
    required String imagePath,
  }) async => asMap(
    apiData(
      await source.storePortfolio(
        {
          'title': title,
          if (description != null && description.isNotEmpty)
            'description': description,
          if (category != null && category.isNotEmpty) 'category': category,
          if (completionDate != null && completionDate.isNotEmpty)
            'completion_date': completionDate,
          if (clientName != null && clientName.isNotEmpty)
            'client_name': clientName,
          if (location != null && location.isNotEmpty) 'location': location,
          if (budget != null) 'budget': budget,
          if (isFeatured != null) 'is_featured': isFeatured,
        },
        image: await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split(RegExp(r'[\\/]')).last,
        ),
      ),
    ),
  );

  Future<void> destroyPortfolio(String id) => source.destroyPortfolio(id);

  // Wallet & withdrawals
  Future<Map<String, dynamic>> wallet() async =>
      asMap(apiData(await source.wallet()));

  Future<List<Map<String, dynamic>>> withdrawals() async =>
      dataList(apiData(await source.withdrawals()));

  Future<Map<String, dynamic>> storeWithdrawal(
    Map<String, dynamic> data,
  ) async => asMap(apiData(await source.storeWithdrawal(data)));

  Future<void> cancelWithdrawal(String id) => source.cancelWithdrawal(id);

  // Reviews
  Future<List<Map<String, dynamic>>> reviews() async =>
      dataList(apiData(await source.reviews()));

  Future<void> replyReview(String id, String reply) =>
      source.replyReview(id, reply);

  // Chat
  Future<List<Map<String, dynamic>>> conversations() async {
    final payload = apiData(await source.conversations());
    final map = asMap(payload);
    return dataList(map['conversations'] ?? map['items'] ?? payload);
  }

  Future<Map<String, dynamic>> conversation(String id) async {
    final payload = apiData(await source.conversation(id));
    final map = asMap(payload);
    return asMap(map['conversation'] ?? map['thread'] ?? payload);
  }

  Future<Map<String, dynamic>> sendMessage(String id, String body) async =>
      asMap(apiData(await source.sendMessage(id, body)));

  // Notifications
  Future<List<Map<String, dynamic>>> notifications({String? page}) async =>
      dataList(apiData(await source.notifications(page: page)));

  Future<void> markNotificationRead(String id) =>
      source.markNotificationRead(id);

  Future<void> markAllNotificationsRead() => source.markAllNotificationsRead();

  // B2B requests
  Future<List<Map<String, dynamic>>> serviceRequests({String? type}) async =>
      dataList(apiData(await source.serviceRequests(type: type)));

  Future<Map<String, dynamic>> storeServiceRequest(
    Map<String, dynamic> data,
  ) async => asMap(apiData(await source.storeServiceRequest(data)));

  Future<Map<String, dynamic>> acceptServiceRequest(String id) async =>
      asMap(apiData(await source.acceptServiceRequest(id)));

  Future<Map<String, dynamic>> rejectServiceRequest(
    String id, {
    String? reason,
  }) async =>
      asMap(apiData(await source.rejectServiceRequest(id, reason: reason)));

  Future<Map<String, dynamic>> completeServiceRequest(String id) async =>
      asMap(apiData(await source.completeServiceRequest(id)));

  // Reports
  Future<Map<String, dynamic>> bookingsReport({
    String? from,
    String? to,
  }) async => asMap(apiData(await source.bookingsReport(from: from, to: to)));

  Future<Map<String, dynamic>> revenueReport({
    String? from,
    String? to,
  }) async => asMap(apiData(await source.revenueReport(from: from, to: to)));
}
