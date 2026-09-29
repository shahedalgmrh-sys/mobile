import '../models/provider_model.dart';
import '../models/service_model.dart';

class HomeFeedData {
  final List<Service> featuredServices;
  final List<Provider> topProviders;
  final List<Service> recentServices;

  const HomeFeedData({
    required this.featuredServices,
    required this.topProviders,
    required this.recentServices,
  });
}

class SearchFilters {
  final double? minPrice;
  final double? maxPrice;
  final String? categoryId;
  final String? cityId;
  final double? minRating;
  final List<int>? providerIds;
  final int? durationMinutesMin;
  final bool? isVerifiedOnly;
  final String? sortBy;
  final String? sortOrder;

  const SearchFilters({
    this.minPrice,
    this.maxPrice,
    this.categoryId,
    this.cityId,
    this.minRating,
    this.providerIds,
    this.durationMinutesMin,
    this.isVerifiedOnly,
    this.sortBy,
    this.sortOrder,
  });
}

class SearchResult {
  final List<Service> services;
  final List<Provider> providers;
  final int totalCount;
  final int currentPage;
  final int lastPage;

  const SearchResult({
    required this.services,
    required this.providers,
    required this.totalCount,
    required this.currentPage,
    required this.lastPage,
  });
}

abstract class IServiceRepository {
  Future<HomeFeedData> homeFeed();

  Future<SearchResult> search(
    String query, {
    SearchFilters? filters,
    int? page,
    int? perPage,
  });

  Future<Service> getBySlug(String slug);

  Future<Provider> getProviderById(String id);

  Future<bool> toggleFavorite(String serviceId);
}
