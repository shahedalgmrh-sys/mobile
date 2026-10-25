// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      id: (json['id'] as num).toInt(),
      bookingId: (json['bookingId'] as num).toInt(),
      type: $enumDecode(_$ReviewTypeEnumMap, json['type']),
      reviewerId: (json['reviewerId'] as num).toInt(),
      revieweeId: (json['revieweeId'] as num).toInt(),
      quality: (json['quality'] as num).toDouble(),
      punctuality: (json['punctuality'] as num?)?.toDouble(),
      communication: (json['communication'] as num?)?.toDouble(),
      valueForMoney: (json['valueForMoney'] as num?)?.toDouble(),
      appointmentKeeping: (json['appointmentKeeping'] as num?)?.toDouble(),
      workspaceNeatness: (json['workspaceNeatness'] as num?)?.toDouble(),
      paymentReadiness: (json['paymentReadiness'] as num?)?.toDouble(),
      comment: json['comment'] as String?,
      photoUrls:
          (json['photoUrls'] as List<dynamic>).map((e) => e as String).toList(),
      isApproved: json['isApproved'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'id': instance.id,
      'bookingId': instance.bookingId,
      'type': _$ReviewTypeEnumMap[instance.type]!,
      'reviewerId': instance.reviewerId,
      'revieweeId': instance.revieweeId,
      'quality': instance.quality,
      'punctuality': instance.punctuality,
      'communication': instance.communication,
      'valueForMoney': instance.valueForMoney,
      'appointmentKeeping': instance.appointmentKeeping,
      'workspaceNeatness': instance.workspaceNeatness,
      'paymentReadiness': instance.paymentReadiness,
      'comment': instance.comment,
      'photoUrls': instance.photoUrls,
      'isApproved': instance.isApproved,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ReviewTypeEnumMap = {
  ReviewType.clientToProvider: 'clientToProvider',
  ReviewType.providerToClient: 'providerToClient',
};
