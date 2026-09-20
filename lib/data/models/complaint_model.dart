import 'package:json_annotation/json_annotation.dart';

import 'package:saber_flutter/core/constants/enums.dart';

part 'complaint_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Complaint {
  final int id;
  final int bookingId;
  final int customerId;
  final String category;
  final String severity;
  final String description;
  final List<String> photoUrls;
  final ComplaintStatus status;
  final String? adminNote;
  final DateTime createdAt;

  const Complaint({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.category,
    required this.severity,
    required this.description,
    required this.photoUrls,
    required this.status,
    this.adminNote,
    required this.createdAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) =>
      _$ComplaintFromJson(json);

  Map<String, dynamic> toJson() => _$ComplaintToJson(this);

  Complaint copyWith({
    int? id,
    int? bookingId,
    int? customerId,
    String? category,
    String? severity,
    String? description,
    List<String>? photoUrls,
    ComplaintStatus? status,
    String? adminNote,
    DateTime? createdAt,
  }) {
    return Complaint(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      photoUrls: photoUrls ?? this.photoUrls,
      status: status ?? this.status,
      adminNote: adminNote ?? this.adminNote,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
