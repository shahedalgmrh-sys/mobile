import '../../models/provider.dart';
import '../../models/service.dart';
import '../sources/remote_sources.dart';
import 'parsers.dart';

class CategoryItem {
  final int id;
  final String slug;
  final String name;
  final String? icon;
  final String? image;
  final int servicesCount;

  const CategoryItem({
    required this.id,
    required this.slug,
    required this.name,
    this.icon,
    this.image,
    this.servicesCount = 0,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> j) => CategoryItem(
        id: toInt(j['id']),
        slug: str(j['slug']),
        name: str(j['name'] ?? j['title'] ?? j['title_ar']),
        icon: strOrNull(j['icon']),
        image: strOrNull(j['image']),
        servicesCount: toInt(j['services_count']),
      );
}

class OfferItem {
  final int id;
  final String title;
  final String? description;
  final String? image;
  final double? discountPercent;

  const OfferItem({
    required this.id,
    required this.title,
    this.description,
    this.image,
    this.discountPercent,
  });

  factory OfferItem.fromJson(Map<String, dynamic> j) => OfferItem(
        id: toInt(j['id']),
        title: str(j['title'] ?? j['title_ar'] ?? j['name']),
        description: strOrNull(j['description'] ?? j['description_ar']),
        image: strOrNull(j['image'] ?? j['image_url']),
        discountPercent: toDoubleOrNull(j['discount'] ?? j['discount_percent']),
      );
}

class HomeFeed {
  final List<CategoryItem> categories;
  final List<Service> featuredServices;
  final List<Service> popularServices;
  final List<OfferItem> offers;
  final List<ProviderModel> featuredProviders;
  final Map<String, dynamic> stats;

  const HomeFeed({
    this.categories = const [],
    this.featuredServices = const [],
    this.popularServices = const [],
    this.offers = const [],
    this.featuredProviders = const [],
    this.stats = const {},
  });
}

Service serviceFromJson(Map<String, dynamic> j) {
  final category = asMap(j['category']);
  return Service(
    id: str(j['id']),
    slug: str(j['slug']),
    titleAr: str(j['name'] ?? j['title'] ?? j['title_ar']),
    titleEn: str(j['name_en'] ?? j['title_en'] ?? j['name'] ?? j['title']),
    descriptionAr: strOrNull(j['description'] ?? j['short_description']),
    descriptionEn: strOrNull(j['description_en'] ?? j['short_description']),
    basePrice: toDouble(j['display_price'] ?? j['price']),
    currencyCode: str(j['display_currency'] ?? j['currency'], 'yer'),
    imageUrl: strOrNull(j['image'] ?? j['thumbnail_url'] ?? j['thumbnail']),
    ratingAvg: toDouble(j['average_rating'] ?? j['rating_avg']),
    reviewsCount: toInt(j['review_count'] ?? j['reviews_count']),
    discountPercent: toDoubleOrNull(j['discount_percent']),
    durationMinutes: toIntOrNull(j['duration_minutes']),
    categoryId: str(category['id'] ?? j['category_id']),
  );
}

ProviderModel providerFromJson(Map<String, dynamic> j) {
  final user = asMap(j['user']);
  return ProviderModel(
    id: str(j['id']),
    userId: str(j['user_id'] ?? user['id']),
    businessName: str(j['business_name'] ?? user['name'] ?? j['full_name']),
    bio: strOrNull(j['business_description'] ?? j['bio']),
    avatarUrl: strOrNull(j['business_logo'] ?? user['avatar'] ?? j['avatar_url']),
    coverImageUrl: strOrNull(j['cover_image'] ?? j['banner']),
    ratingAvg: toDouble(j['average_rating'] ?? j['rating_avg']),
    totalReviews: toInt(j['total_reviews'] ?? j['reviews_count']),
    isVerified: toBool(j['is_verified'] ?? (j['verification_status'] == 'verified')),
    isOnline: toBool(j['is_available']),
    city: strOrNull(j['city'] ?? j['city_ar']),
    completedBookings: toInt(j['total_bookings'] ?? j['completed_bookings_count']),
    hourlyRate: toDoubleOrNull(j['hourly_rate'] ?? j['hourly_rate_from']),
  );
}

class CatalogRepository {
  final CatalogRemoteSource source;
  const CatalogRepository(this.source);

  Future<HomeFeed> home() async {
    final res = await source.home();
    final d = asMap(apiData(res));
    return HomeFeed(
      categories: dataList(d['categories']).map(CategoryItem.fromJson).toList(),
      featuredServices: dataList(d['featured_services']).map(serviceFromJson).toList(),
      popularServices: dataList(d['popular_services']).map(serviceFromJson).toList(),
      offers: dataList(d['offers']).map(OfferItem.fromJson).toList(),
      featuredProviders: dataList(d['featured_providers']).map(providerFromJson).toList(),
      stats: asMap(d['stats']),
    );
  }

  Future<List<CategoryItem>> categories() async {
    final res = await source.categories();
    return dataList(apiData(res)).map(CategoryItem.fromJson).toList();
  }

  Future<List<Service>> services({String? q, int? categoryId, String? sort, int? page}) async {
    final res = await source.services(q: q, categoryId: categoryId, sort: sort, page: page);
    return dataList(apiData(res)).map(serviceFromJson).toList();
  }

  Future<List<ProviderModel>> providers({int? cityId, int? page}) async {
    final res = await source.providers(cityId: cityId, page: page);
    return dataList(apiData(res)).map(providerFromJson).toList();
  }

  Future<ProviderModel> providerProfile(int id) async {
    final res = await source.providerProfile(id);
    final d = asMap(apiData(res));
    final p = asMap(d['provider']);
    return providerFromJson(p.isEmpty ? d : p);
  }

  /// GET /providers/{id} → {provider, services, portfolios, reviews}
  Future<Map<String, dynamic>> providerProfileFull(int id) async {
    final res = await source.providerProfile(id);
    return asMap(apiData(res));
  }

  Future<List<OfferItem>> offers() async {
    final res = await source.offers();
    return dataList(apiData(res)).map(OfferItem.fromJson).toList();
  }

  Future<List<Map<String, dynamic>>> cities() async {
    final res = await source.cities();
    return dataList(apiData(res));
  }

  Future<List<Map<String, dynamic>>> cityAreas(int cityId) async {
    final res = await source.cityAreas(cityId);
    return dataList(apiData(res));
  }

  Future<List<Map<String, dynamic>>> faqs({String? category}) async {
    final res = await source.faqs(category: category);
    return dataList(apiData(res));
  }

  Future<void> sendContactMessage({
    required String name,
    required String email,
    String? phone,
    required String subject,
    required String message,
  }) async =>
      apiData(await source.contact({
        'name': name,
        'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'subject': subject,
        'message': message,
      }));
}
