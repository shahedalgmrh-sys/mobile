import 'package:json_annotation/json_annotation.dart';

import 'package:saber_flutter/core/constants/enums.dart';

part 'review_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Review {
  final int id;
  final int bookingId;
  final ReviewType type;
  final int reviewerId;
  final int revieweeId;
  final double quality;
  final double? punctuality;
  final double? communication;
  final double? valueForMoney;
  final double? appointmentKeeping;
  final double? workspaceNeatness;
  final double? paymentReadiness;
  final String? comment;
  final List<String> photoUrls;
  final bool isApproved;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.bookingId,
    required this.type,
    required this.reviewerId,
    required this.revieweeId,
    required this.quality,
    this.punctuality,
    this.communication,
    this.valueForMoney,
    this.appointmentKeeping,
    this.workspaceNeatness,
    this.paymentReadiness,
    this.comment,
    required this.photoUrls,
    required this.isApproved,
    required this.createdAt,
  });

  double get overall {
    if (type == ReviewType.clientToProvider) {
      final values = [quality, punctuality, communication, valueForMoney];
      final validValues = values.whereType<double>().toList();
      if (validValues.isEmpty) return 0.0;
      return validValues.reduce((a, b) => a + b) / validValues.length;
    } else {
      final values = [
        quality,
        appointmentKeeping,
        workspaceNeatness,
        paymentReadiness,
      ];
      final validValues = values.whereType<double>().toList();
      if (validValues.isEmpty) return 0.0;
      return validValues.reduce((a, b) => a + b) / validValues.length;
    }
  }

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);

  Review copyWith({
    int? id,
    int? bookingId,
    ReviewType? type,
    int? reviewerId,
    int? revieweeId,
    double? quality,
    double? punctuality,
    double? communication,
    double? valueForMoney,
    double? appointmentKeeping,
    double? workspaceNeatness,
    double? paymentReadiness,
    String? comment,
    List<String>? photoUrls,
    bool? isApproved,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      type: type ?? this.type,
      reviewerId: reviewerId ?? this.reviewerId,
      revieweeId: revieweeId ?? this.revieweeId,
      quality: quality ?? this.quality,
      punctuality: punctuality ?? this.punctuality,
      communication: communication ?? this.communication,
      valueForMoney: valueForMoney ?? this.valueForMoney,
      appointmentKeeping: appointmentKeeping ?? this.appointmentKeeping,
      workspaceNeatness: workspaceNeatness ?? this.workspaceNeatness,
      paymentReadiness: paymentReadiness ?? this.paymentReadiness,
      comment: comment ?? this.comment,
      photoUrls: photoUrls ?? this.photoUrls,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
