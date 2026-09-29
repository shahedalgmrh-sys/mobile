import 'package:dio/dio.dart';

import '../sources/remote_sources.dart';
import 'parsers.dart';

/// Provider-side repository — decoded API payloads for the provider app.
class ProviderRepository {
  final ProviderRemoteSource source;
  const ProviderRepository(this.source);

  Future<Map<String, dynamic>> dashboard() async =>
      asMap(apiData(await source.dashboard()));

  Future<Map<String, dynamic>> profile() async =>
      asMap(apiData(await source.profile()));

  Future<Map<String, dynamic>> verificationStatus() async =>
      asMap(apiData(await source.verificationStatus()));

  Future<void> submitVerification({
    List<String> filePaths = const [],
    String? notes,
  }) async {
    final docs = <MultipartFile>[
      for (final p in filePaths)
        await MultipartFile.fromFile(p,
            filename: p.split(RegExp(r'[\\/]')).last),
    ];
    await apiData(await source.submitVerification(
      {if (notes != null && notes.isNotEmpty) 'notes': notes},
      documents: docs.isEmpty ? null : docs,
    ));
  }

  // Services
  Future<List<Map<String, dynamic>>> services() async =>
      dataList(apiData(await source.services()));

  Future<Map<String, dynamic>> storeService(Map<String, dynamic> data) async =>
      asMap(apiData(await source.storeService(data)));

  Future<Map<String, dynamic>> updateService(String id, Map<String, dynamic> data) async =>
      asMap(apiData(await source.updateService(id, data)));

  Future<void> destroyService(String id) => source.destroyService(id);

  Future<Map<String, dynamic>> toggleService(String id) async =>
      asMap(apiData(await source.toggleService(id)));

  Future<Map<String, dynamic>> duplicateService(String id) async =>
      asMap(apiData(await source.duplicateService(id)));

  // Bookings
  Future<List<Map<String, dynamic>>> bookings({String? status, String? date, int? page}) async =>
      dataList(apiData(await source.bookings(status: status, date: date, page: page)));

  Future<Map<String, dynamic>> booking(String id) async =>
      asMap(apiData(await source.showBooking(id)));

  Future<Map<String, dynamic>> acceptBooking(String id) async =>
      asMap(apiData(await source.acceptBooking(id)));

  Future<Map<String, dynamic>> rejectBooking(String id, {String? reason}) async =>
      asMap(apiData(await source.rejectBooking(id, reason: reason)));

  Future<Map<String, dynamic>> startBooking(String id) async =>
      asMap(apiData(await source.startBooking(id)));

  Future<Map<String, dynamic>> completeBooking(String id) async =>
      asMap(apiData(await source.completeBooking(id)));

  Future<Map<String, dynamic>> rescheduleBooking(String id, String date, String time,
          {String? reason}) async =>
      asMap(apiData(await source.rescheduleBooking(id, date, time, reason: reason)));

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

  Future<void> destroyPortfolio(String id) => source.destroyPortfolio(id);

  // Wallet & withdrawals
  Future<Map<String, dynamic>> wallet() async =>
      asMap(apiData(await source.wallet()));

  Future<List<Map<String, dynamic>>> withdrawals() async =>
      dataList(apiData(await source.withdrawals()));

  Future<Map<String, dynamic>> storeWithdrawal(Map<String, dynamic> data) async =>
      asMap(apiData(await source.storeWithdrawal(data)));

  Future<void> cancelWithdrawal(String id) => source.cancelWithdrawal(id);

  // Reviews
  Future<List<Map<String, dynamic>>> reviews() async =>
      dataList(apiData(await source.reviews()));

  Future<void> replyReview(String id, String reply) => source.replyReview(id, reply);

  // Chat
  Future<List<Map<String, dynamic>>> conversations() async =>
      dataList(apiData(await source.conversations()));

  Future<Map<String, dynamic>> conversation(String id) async =>
      asMap(apiData(await source.conversation(id)));

  Future<Map<String, dynamic>> sendMessage(String id, String body) async =>
      asMap(apiData(await source.sendMessage(id, body)));

  // Notifications
  Future<List<Map<String, dynamic>>> notifications({String? page}) async =>
      dataList(apiData(await source.notifications(page: page)));

  Future<void> markNotificationRead(String id) => source.markNotificationRead(id);

  Future<void> markAllNotificationsRead() => source.markAllNotificationsRead();

  // B2B requests
  Future<List<Map<String, dynamic>>> serviceRequests({String? type}) async =>
      dataList(apiData(await source.serviceRequests(type: type)));

  Future<Map<String, dynamic>> storeServiceRequest(Map<String, dynamic> data) async =>
      asMap(apiData(await source.storeServiceRequest(data)));

  Future<Map<String, dynamic>> acceptServiceRequest(String id) async =>
      asMap(apiData(await source.acceptServiceRequest(id)));

  Future<Map<String, dynamic>> rejectServiceRequest(String id, {String? reason}) async =>
      asMap(apiData(await source.rejectServiceRequest(id, reason: reason)));

  Future<Map<String, dynamic>> completeServiceRequest(String id) async =>
      asMap(apiData(await source.completeServiceRequest(id)));

  // Reports
  Future<Map<String, dynamic>> bookingsReport({String? from, String? to}) async =>
      asMap(apiData(await source.bookingsReport(from: from, to: to)));

  Future<Map<String, dynamic>> revenueReport({String? from, String? to}) async =>
      asMap(apiData(await source.revenueReport(from: from, to: to)));
}
