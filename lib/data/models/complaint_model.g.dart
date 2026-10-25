// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Complaint _$ComplaintFromJson(Map<String, dynamic> json) => Complaint(
      id: (json['id'] as num).toInt(),
      bookingId: (json['bookingId'] as num).toInt(),
      customerId: (json['customerId'] as num).toInt(),
      category: json['category'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String,
      photoUrls:
          (json['photoUrls'] as List<dynamic>).map((e) => e as String).toList(),
      status: $enumDecode(_$ComplaintStatusEnumMap, json['status']),
      adminNote: json['adminNote'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ComplaintToJson(Complaint instance) => <String, dynamic>{
      'id': instance.id,
      'bookingId': instance.bookingId,
      'customerId': instance.customerId,
      'category': instance.category,
      'severity': instance.severity,
      'description': instance.description,
      'photoUrls': instance.photoUrls,
      'status': _$ComplaintStatusEnumMap[instance.status]!,
      'adminNote': instance.adminNote,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ComplaintStatusEnumMap = {
  ComplaintStatus.pending: 'pending',
  ComplaintStatus.investigating: 'investigating',
  ComplaintStatus.resolved: 'resolved',
  ComplaintStatus.rejected: 'rejected',
};
