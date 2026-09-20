class Service {
  final String id;
  final String slug;
  final String titleAr;
  final String titleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final double basePrice;
  final String currencyCode;
  final String? imageUrl;
  final double ratingAvg;
  final int reviewsCount;
  final double? discountPercent;
  final int? durationMinutes;
  final String categoryId;

  const Service({
    required this.id,
    required this.slug,
    required this.titleAr,
    required this.titleEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.basePrice,
    required this.currencyCode,
    this.imageUrl,
    this.ratingAvg = 0.0,
    this.reviewsCount = 0,
    this.discountPercent,
    this.durationMinutes,
    required this.categoryId,
  });
}
