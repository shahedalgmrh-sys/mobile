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

  Future<Booking> accept(int bookingId);

  Future<Booking> reject(int bookingId);

  Future<Booking> start(int bookingId);

  Future<Booking> complete(int bookingId);

  Future<Booking> cancel(int bookingId, String reason);

  Future<Booking> getById(int bookingId);

  Future<List<String>> uploadWorkProof(
    int bookingId,
    List<MultipartFile> files,
  );
}
