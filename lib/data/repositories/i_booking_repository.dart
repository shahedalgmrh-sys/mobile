import 'package:dio/dio.dart';

import '../models/booking_model.dart';

abstract class IBookingRepository {
  Future<Booking> create(Map<String, dynamic> data);

  Future<List<Booking>> getCustomerBookings({
    int? page,
    int? perPage,
    String? status,
  });

  Future<List<Booking>> getProviderBookings({
    int? page,
    int? perPage,
    String? status,
  });

  Future<Booking> accept(String bookingId);

  Future<Booking> reject(String bookingId);

  Future<Booking> start(String bookingId);

  Future<Booking> complete(String bookingId);

  Future<Booking> cancel(String bookingId, String reason);

  Future<Booking> getById(String bookingId);

  Future<List<String>> uploadWorkProof(
    String bookingId,
    List<MultipartFile> files,
  );
}
