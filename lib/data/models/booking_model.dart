import 'package:json_annotation/json_annotation.dart';

import 'package:saber_flutter/core/constants/enums.dart';

part 'booking_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Booking {
  final int id;
  final String bookingNumber;
  final BookingStatus status;
  final int customerId;
  final int? providerId;
  final int serviceId;
  final String? serviceTitle;
  final String? providerName;
  final String? providerAvatar;
  final double subtotal;
  final double discount;
  final double platformFee;
  final double tax;
  final double total;
  final String currencyCode;
  final DateTime? scheduledDate;
  final String? scheduledTimeSlot;
  final String? addressJson;
  final String? customerNotes;
  final List<String>? problemImageUrls;
  final List<String>? workProofImageUrls;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final double? latitude;
  final double? longitude;
  final bool? isCustomerCancellationAllowed;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.bookingNumber,
    required this.status,
    required this.customerId,
    this.providerId,
    required this.serviceId,
    this.serviceTitle,
    this.providerName,
    this.providerAvatar,
    required this.subtotal,
    required this.discount,
    required this.platformFee,
    required this.tax,
    required this.total,
    required this.currencyCode,
    this.scheduledDate,
    this.scheduledTimeSlot,
    this.addressJson,
    this.customerNotes,
    this.problemImageUrls,
    this.workProofImageUrls,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.latitude,
    this.longitude,
    this.isCustomerCancellationAllowed,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

  Map<String, dynamic> toJson() => _$BookingToJson(this);

  Booking copyWith({
    int? id,
    String? bookingNumber,
    BookingStatus? status,
    int? customerId,
    int? providerId,
    int? serviceId,
    String? serviceTitle,
    String? providerName,
    String? providerAvatar,
    double? subtotal,
    double? discount,
    double? platformFee,
    double? tax,
    double? total,
    String? currencyCode,
    DateTime? scheduledDate,
    String? scheduledTimeSlot,
    String? addressJson,
    String? customerNotes,
    List<String>? problemImageUrls,
    List<String>? workProofImageUrls,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    double? latitude,
    double? longitude,
    bool? isCustomerCancellationAllowed,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      bookingNumber: bookingNumber ?? this.bookingNumber,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      serviceId: serviceId ?? this.serviceId,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      providerName: providerName ?? this.providerName,
      providerAvatar: providerAvatar ?? this.providerAvatar,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      platformFee: platformFee ?? this.platformFee,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      currencyCode: currencyCode ?? this.currencyCode,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTimeSlot: scheduledTimeSlot ?? this.scheduledTimeSlot,
      addressJson: addressJson ?? this.addressJson,
      customerNotes: customerNotes ?? this.customerNotes,
      problemImageUrls: problemImageUrls ?? this.problemImageUrls,
      workProofImageUrls: workProofImageUrls ?? this.workProofImageUrls,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isCustomerCancellationAllowed: isCustomerCancellationAllowed ?? this.isCustomerCancellationAllowed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
