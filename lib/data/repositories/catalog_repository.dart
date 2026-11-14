import '../../models/provider.dart';
import '../../models/service.dart';
import '../sources/remote_sources.dart';
import 'parsers.dart';

class CategoryItem {
  final String id;
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
    id: str(j['id']),
    slug: str(j['slug']),
    name: str(j['name'] ?? j['title'] ?? j['title_ar']),
    icon: strOrNull(j['icon']),
    image: strOrNull(j['image']),
    servicesCount: toInt(j['services_count']),
  );
}

class OfferItem {
  final String id;
  final String slug;
  final String title;
  final String? description;
  final String? image;
  final double? discountPercent;
  final String? discountType;
  final double? discountValue;
  final double? minPurchase;
  final String? startDate;
  final String? endDate;
  final bool isRunning;

  const OfferItem({
    required this.id,
    this.slug = '',
    required this.title,
    this.description,
    this.image,
    this.discountPercent,
    this.discountType,
    this.discountValue,
    this.minPurchase,
    this.startDate,
    this.endDate,
    this.isRunning = false,
  });

  factory OfferItem.fromJson(Map<String, dynamic> j) {
    final type = str(j['discount_type']).toLowerCase();
    final value = toDoubleOrNull(j['discount_value'] ?? j['discount']);
    return OfferItem(
      id: str(j['id']),
      slug: str(j['slug']),
      title: str(j['title'] ?? j['title_ar'] ?? j['name']),
      description: strOrNull(j['description'] ?? j['description_ar']),
      image: strOrNull(j['image'] ?? j['image_url']),
      discountPercent:
          toDoubleOrNull(j['discount_percent'] ?? j['discount']) ??
          ((type == 'percentage' || type == 'percent') ? value : null),
      discountType: type.isEmpty ? null : type,
      discountValue: value,
      minPurchase: toDoubleOrNull(j['min_purchase']),
      startDate: strOrNull(j['start_date']),
      endDate: strOrNull(j['end_date']),
      isRunning: toBool(j['is_running']),
    );
  }
}

class BlogItem {
  final String id;
  final String title;
  final String slug;
  final String? excerpt;
  final String? image;
  final String? category;
  final String? date;

  const BlogItem({
    required this.id,
    required this.title,
    required this.slug,
    this.excerpt,
    this.image,
    this.category,
    this.date,
  });

  factory BlogItem.fromJson(Map<String, dynamic> j) {
    final content = str(j['content'] ?? j['description']);
    return BlogItem(
      id: str(j['id']),
      title: str(j['title'] ?? j['title_ar']),
      slug: str(j['slug']),
      excerpt: strOrNull(
        j['excerpt'] ??
            (content.length > 140 ? content.substring(0, 140) : content),
      ),
      image: strOrNull(j['image']),
      category: strOrNull(j['category']),
      date: strOrNull(
        j['date_ar'] ?? j['formatted_published_at'] ?? j['published_at'],
      ),
    );
  }
}

class AdBanner {
  final String id;
  final String title;
  final String? image;
  final String? link;
  final String? position;

  const AdBanner({
    required this.id,
    required this.title,
    this.image,
    this.link,
    this.position,
  });

  factory AdBanner.fromJson(Map<String, dynamic> j) => AdBanner(
    id: str(j['id']),
    title: str(j['title'] ?? j['name']),
    image: strOrNull(j['image'] ?? j['banner'] ?? j['image_url']),
    link: strOrNull(j['link'] ?? j['url']),
    position: strOrNull(j['position']),
  );
}

class HomeFeed {
  final List<CategoryItem> categories;
  final List<Service> featuredServices;
  final List<Service> popularServices;
  final List<OfferItem> offers;
  final List<ProviderModel> featuredProviders;
  final List<BlogItem> latestBlogs;
  final Map<String, dynamic> stats;

  const HomeFeed({
    this.categories = const [],
    this.featuredServices = const [],
    this.popularServices = const [],
    this.offers = const [],
    this.featuredProviders = const [],
    this.latestBlogs = const [],
    this.stats = const {},
  });
}

/// One page of a public catalog list.
class CatalogPage<T> {
  const CatalogPage({
    required this.items,
    required this.currentPage,
    required this.hasMore,
    required this.total,
  });

  final List<T> items;
  final int currentPage;
  final bool hasMore;
  final int total;
}

String? _firstImage(dynamic raw) {
  for (final item in asList(raw)) {
    final value = item is Map
        ? str(item['url'] ?? item['image'] ?? item['path'])
        : str(item);
    if (value.isNotEmpty) return value;
  }
  return null;
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
    imageUrl: strOrNull(
      j['image'] ??
          j['thumbnail_url'] ??
          j['thumbnail'] ??
          _firstImage(j['images']),
    ),
    ratingAvg: toDouble(j['average_rating'] ?? j['rating_avg']),
    reviewsCount: toInt(j['review_count'] ?? j['reviews_count']),
    discountPercent: toDoubleOrNull(j['discount_percent']),
    durationMinutes: toIntOrNull(j['duration_minutes']),
    categoryId: str(category['id'] ?? j['category_id']),
    distanceKm: toDoubleOrNull(j['distance_km']),
    pricing: dataList(j['pricing']).map(ServicePricing.fromJson).toList(),
    isAvailable: toBool(j['is_available'] ?? j['is_active'], true),
  );
}

ProviderModel providerFromJson(Map<String, dynamic> j) {
  final user = asMap(j['user']);
  return ProviderModel(
    id: str(j['id']),
    userId: str(j['user_id'] ?? user['id']),
    businessName: str(j['business_name'] ?? user['name'] ?? j['full_name']),
    bio: strOrNull(j['business_description'] ?? j['bio']),
    avatarUrl: strOrNull(
      j['business_logo'] ?? user['avatar'] ?? j['avatar_url'],
    ),
    coverImageUrl: strOrNull(
      j['cover_image'] ?? j['business_cover'] ?? j['banner'],
    ),
    ratingAvg: toDouble(j['average_rating'] ?? j['rating_avg']),
    totalReviews: toInt(j['total_reviews'] ?? j['reviews_count']),
    isVerified: toBool(
      j['is_verified'] ?? (j['verification_status'] == 'verified'),
    ),
    isOnline: toBool(j['is_available']),
    lat: toDoubleOrNull(j['latitude']),
    lng: toDoubleOrNull(j['longitude']),
    city: strOrNull(j['city'] ?? j['city_ar']),
    completedBookings: toInt(
      j['total_bookings'] ?? j['completed_bookings_count'],
    ),
    servicesCount: toInt(j['services_count']),
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
      featuredServices: dataList(d['featured_services'])
          .map(serviceFromJson)
          .toList(),
      popularServices: dataList(d['popular_services'])
          .map(serviceFromJson)
          .toList(),
      offers: dataList(d['offers']).map(OfferItem.fromJson).toList(),
      featuredProviders: dataList(d['featured_providers'])
          .map(providerFromJson)
          .toList(),
      latestBlogs: dataList(d['latest_blogs'] ?? d['blogs'])
          .map(BlogItem.fromJson)
          .toList(),
      stats: asMap(d['stats']),
    );
  }

  Future<List<CategoryItem>> categories() async {
    final res = await source.categories();
    return dataList(apiData(res)).map(CategoryItem.fromJson).toList();
  }

  Future<List<AdBanner>> ads() async {
    final res = await source.ads();
    return dataList(apiData(res)).map(AdBanner.fromJson).toList();
  }

  Future<List<BlogItem>> blogs({int? page}) async {
    final res = await source.blogs(page: page);
    final envelope = asMap(res.data);
    final items = dataList(
      envelope.containsKey('data') ? envelope['data'] : res.data,
    );
    return items.map(BlogItem.fromJson).toList();
  }

  Future<Map<String, dynamic>> showBlog(String slug) async =>
      asMap(apiData(await source.showBlog(slug)));

  Future<Map<String, dynamic>> contentPage(String slug) async =>
      asMap(apiData(await source.page(slug)));

  Future<List<Map<String, dynamic>>> currencies() async {
    final res = await source.currencies();
    return dataList(apiData(res));
  }

  Future<List<String>> popularSearches() async {
    final res = await source.popularSearches();
    final d = apiData(res);
    if (d is List) {
      return d.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    final map = asMap(d);
    return dataList(map['queries'] ?? map['terms'] ?? map['popular'])
        .map((e) {
          final item = asMap(e);
          return str(item['query'] ?? item['term'] ?? e, '');
        })
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<List<Service>> services({
    String? q,
    String? categoryId,
    String? sort,
    int? page,
  }) async {
    // The public endpoint ignores q/category/sort and paginates by `limit`;
    // ask for a larger first page so detail deep links can still resolve.
    final res = await source.services(
      q: q,
      categoryId: categoryId,
      sort: sort,
      page: page,
      limit: 50,
    );
    return dataList(apiData(res)).map(serviceFromJson).toList();
  }

  /// GET /providers → `{status, data: [...], meta: {current_page, last_page,
  /// total}}`. The pagination metadata is read before [apiData] unwraps it.
  Future<CatalogPage<ProviderModel>> providersPage({
    String? cityId,
    String? q,
    String? sort,
    int page = 1,
    int perPage = 12,
  }) async {
    final res = await source.providers(
      cityId: cityId,
      q: q,
      sort: sort,
      page: page,
      perPage: perPage,
    );
    final envelope = asMap(res.data);
    final items = dataList(
      envelope.containsKey('data') ? envelope['data'] : res.data,
    );
    final meta = asMap(envelope['meta']);
    final current = toInt(meta['current_page'], page);
    final last = toInt(meta['last_page'], current);
    return CatalogPage(
      items: items.map(providerFromJson).toList(),
      currentPage: current,
      hasMore: current < last,
      total: toInt(meta['total'], items.length),
    );
  }

  Future<ProviderModel> providerProfile(String id) async {
    final res = await source.providerProfile(id);
    final d = asMap(apiData(res));
    final p = asMap(d['provider']);
    return providerFromJson(p.isEmpty ? d : p);
  }

  /// GET /providers/{id} → {provider, services, portfolios, reviews}
  Future<Map<String, dynamic>> providerProfileFull(String id) async {
    final res = await source.providerProfile(id);
    return asMap(apiData(res));
  }

  /// GET /offers → `{status, data: [...]}`. The API does not expose pagination
  /// metadata for this endpoint, so the presence of a full page is the only
  /// signal that another page may exist.
  Future<CatalogPage<OfferItem>> offersPage({
    int page = 1,
    int perPage = 12,
  }) async {
    final res = await source.offers(page: page, perPage: perPage);
    final envelope = asMap(res.data);
    final items = dataList(
      envelope.containsKey('data') ? envelope['data'] : res.data,
    );
    return CatalogPage(
      items: items.map(OfferItem.fromJson).toList(),
      currentPage: page,
      hasMore: items.length >= perPage,
      total: items.length,
    );
  }

  Future<List<Map<String, dynamic>>> cities() async {
    final res = await source.cities();
    return dataList(apiData(res));
  }

  Future<List<Map<String, dynamic>>> cityAreas(String cityId) async {
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
  }) async => apiData(
    await source.contact({
      'name': name,
      'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      'subject': subject,
      'message': message,
    }),
  );
}
