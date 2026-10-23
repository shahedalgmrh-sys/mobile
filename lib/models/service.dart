/// UI-layer models (presentation).
///
/// These lightweight view models exist solely for widgets & screens: they are
/// produced by the shared repository parsers and carry only display-facing
/// state. They are intentionally SEPARATE from `lib/data/models/*`, which are
/// the network models (freezed/serialized) used by repositories &remote
/// sources. A widget must never import `data/models`; a repository must never
/// emit `lib/models` objects outside its parsers.
library;
import '../data/repositories/parsers.dart';

class ServicePricing {
  final String id;
  final String name;
  final double price;
  final double? discountPrice;
  final double effectivePrice;
  final int? durationMinutes;

  const ServicePricing({
    required this.id,
    required this.name,
    required this.price,
    required this.effectivePrice,
    this.discountPrice,
    this.durationMinutes,
  });

  factory ServicePricing.fromJson(Map<String, dynamic> j) => ServicePricing(
    id: str(j['id']),
    name: str(j['name']),
    price: toDouble(j['price']),
    discountPrice: toDoubleOrNull(j['discount_price']),
    effectivePrice: toDouble(j['effective_price'] ?? j['price']),
    durationMinutes: toIntOrNull(j['duration_minutes']),
  );
}

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
  final double? distanceKm;
  final List<ServicePricing> pricing;
  final bool isAvailable;

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
    this.distanceKm,
    this.pricing = const [],
    this.isAvailable = true,
  });
}
