// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Provider _$ProviderFromJson(Map<String, dynamic> json) => Provider(
      userId: (json['userId'] as num).toInt(),
      businessName: json['businessName'] as String,
      bioAr: json['bioAr'] as String?,
      bioEn: json['bioEn'] as String?,
      ratingAvg: (json['ratingAvg'] as num).toDouble(),
      totalReviews: (json['totalReviews'] as num).toInt(),
      completedBookings: (json['completedBookings'] as num).toInt(),
      isVerified: json['isVerified'] as bool,
      licenseNumber: json['licenseNumber'] as String?,
      coverPhoto: json['coverPhoto'] as String?,
      serviceAreaCityIds: (json['serviceAreaCityIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      workingHours: json['workingHours'] as Map<String, dynamic>?,
      portfolioUrls: (json['portfolioUrls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      walletBalance: (json['walletBalance'] as num).toDouble(),
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      verificationDate: json['verificationDate'] == null
          ? null
          : DateTime.parse(json['verificationDate'] as String),
    );

Map<String, dynamic> _$ProviderToJson(Provider instance) => <String, dynamic>{
      'userId': instance.userId,
      'businessName': instance.businessName,
      'bioAr': instance.bioAr,
      'bioEn': instance.bioEn,
      'ratingAvg': instance.ratingAvg,
      'totalReviews': instance.totalReviews,
      'completedBookings': instance.completedBookings,
      'isVerified': instance.isVerified,
      'licenseNumber': instance.licenseNumber,
      'coverPhoto': instance.coverPhoto,
      'serviceAreaCityIds': instance.serviceAreaCityIds,
      'workingHours': instance.workingHours,
      'portfolioUrls': instance.portfolioUrls,
      'walletBalance': instance.walletBalance,
      'totalEarnings': instance.totalEarnings,
      'verificationDate': instance.verificationDate?.toIso8601String(),
    };
