// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
      id: (json['id'] as num).toInt(),
      bookingNumber: json['bookingNumber'] as String,
      status: $enumDecode(_$BookingStatusEnumMap, json['status']),
      customerId: (json['customerId'] as num).toInt(),
      providerId: (json['providerId'] as num?)?.toInt(),
      serviceId: (json['serviceId'] as num).toInt(),
      serviceTitle: json['serviceTitle'] as String?,
      providerName: json['providerName'] as String?,
      providerAvatar: json['providerAvatar'] as String?,
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      platformFee: (json['platformFee'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
      scheduledDate: json['scheduledDate'] == null
          ? null
          : DateTime.parse(json['scheduledDate'] as String),
      scheduledTimeSlot: json['scheduledTimeSlot'] as String?,
      addressJson: json['addressJson'] as String?,
      customerNotes: json['customerNotes'] as String?,
      problemImageUrls: (json['problemImageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      workProofImageUrls: (json['workProofImageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      acceptedAt: json['acceptedAt'] == null
          ? null
          : DateTime.parse(json['acceptedAt'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      cancellationReason: json['cancellationReason'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isCustomerCancellationAllowed:
          json['isCustomerCancellationAllowed'] as bool?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
      'id': instance.id,
      'bookingNumber': instance.bookingNumber,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'customerId': instance.customerId,
      'providerId': instance.providerId,
      'serviceId': instance.serviceId,
      'serviceTitle': instance.serviceTitle,
      'providerName': instance.providerName,
      'providerAvatar': instance.providerAvatar,
      'subtotal': instance.subtotal,
      'discount': instance.discount,
      'platformFee': instance.platformFee,
      'tax': instance.tax,
      'total': instance.total,
      'currencyCode': instance.currencyCode,
      'scheduledDate': instance.scheduledDate?.toIso8601String(),
      'scheduledTimeSlot': instance.scheduledTimeSlot,
      'addressJson': instance.addressJson,
      'customerNotes': instance.customerNotes,
      'problemImageUrls': instance.problemImageUrls,
      'workProofImageUrls': instance.workProofImageUrls,
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'cancellationReason': instance.cancellationReason,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'isCustomerCancellationAllowed': instance.isCustomerCancellationAllowed,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'pending',
  BookingStatus.accepted: 'accepted',
  BookingStatus.inProgress: 'inProgress',
  BookingStatus.paid: 'paid',
  BookingStatus.completed: 'completed',
  BookingStatus.rejected: 'rejected',
  BookingStatus.rescheduled: 'rescheduled',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.refunded: 'refunded',
};
