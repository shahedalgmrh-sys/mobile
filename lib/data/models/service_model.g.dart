// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Service _$ServiceFromJson(Map<String, dynamic> json) => Service(
      id: (json['id'] as num).toInt(),
      slug: json['slug'] as String,
      titleAr: json['titleAr'] as String,
      titleEn: json['titleEn'] as String,
      descriptionAr: json['descriptionAr'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
      categoryId: (json['categoryId'] as num).toInt(),
      basePrice: (json['basePrice'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      isActive: json['isActive'] as bool,
      ratingAvg: (json['ratingAvg'] as num).toDouble(),
      reviewsCount: (json['reviewsCount'] as num).toInt(),
      completedCount: (json['completedCount'] as num).toInt(),
      isVerified: json['isVerified'] as bool,
      providerId: (json['providerId'] as num?)?.toInt(),
      imageUrls:
          (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ServiceToJson(Service instance) => <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'titleAr': instance.titleAr,
      'titleEn': instance.titleEn,
      'descriptionAr': instance.descriptionAr,
      'descriptionEn': instance.descriptionEn,
      'categoryId': instance.categoryId,
      'basePrice': instance.basePrice,
      'currencyCode': instance.currencyCode,
      'durationMinutes': instance.durationMinutes,
      'isActive': instance.isActive,
      'ratingAvg': instance.ratingAvg,
      'reviewsCount': instance.reviewsCount,
      'completedCount': instance.completedCount,
      'isVerified': instance.isVerified,
      'providerId': instance.providerId,
      'imageUrls': instance.imageUrls,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
