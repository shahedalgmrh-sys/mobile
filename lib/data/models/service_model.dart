import 'package:json_annotation/json_annotation.dart';

part 'service_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Service {
  final int id;
  final String slug;
  final String titleAr;
  final String titleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final int categoryId;
  final double basePrice;
  final String currencyCode;
  final int durationMinutes;
  final bool isActive;
  final double ratingAvg;
  final int reviewsCount;
  final int completedCount;
  final bool isVerified;
  final int? providerId;
  final List<String> imageUrls;
  final DateTime? createdAt;

  const Service({
    required this.id,
    required this.slug,
    required this.titleAr,
    required this.titleEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.categoryId,
    required this.basePrice,
    required this.currencyCode,
    required this.durationMinutes,
    required this.isActive,
    required this.ratingAvg,
    required this.reviewsCount,
    required this.completedCount,
    required this.isVerified,
    this.providerId,
    required this.imageUrls,
    this.createdAt,
  });

  String title(String lang) => lang == 'ar' ? titleAr : titleEn;

  factory Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceToJson(this);

  Service copyWith({
    int? id,
    String? slug,
    String? titleAr,
    String? titleEn,
    String? descriptionAr,
    String? descriptionEn,
    int? categoryId,
    double? basePrice,
    String? currencyCode,
    int? durationMinutes,
    bool? isActive,
    double? ratingAvg,
    int? reviewsCount,
    int? completedCount,
    bool? isVerified,
    int? providerId,
    List<String>? imageUrls,
    DateTime? createdAt,
  }) {
    return Service(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      categoryId: categoryId ?? this.categoryId,
      basePrice: basePrice ?? this.basePrice,
      currencyCode: currencyCode ?? this.currencyCode,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isActive: isActive ?? this.isActive,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      completedCount: completedCount ?? this.completedCount,
      isVerified: isVerified ?? this.isVerified,
      providerId: providerId ?? this.providerId,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
