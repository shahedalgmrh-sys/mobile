import 'booking_status.dart';

class ProviderModel {
  final String id;
  final String userId;
  final String businessName;
  final String? bio;
  final String? avatarUrl;
  final String? coverImageUrl;
  final double ratingAvg;
  final int totalReviews;
  final bool isVerified;
  final bool isOnline;
  final double? lat;
  final double? lng;
  final String? city;
  final int completedBookings;
  final List<String> serviceIds;
  final double? hourlyRate;

  const ProviderModel({
    required this.id,
    required this.userId,
    required this.businessName,
    this.bio,
    this.avatarUrl,
    this.coverImageUrl,
    this.ratingAvg = 0.0,
    this.totalReviews = 0,
    this.isVerified = false,
    this.isOnline = false,
    this.lat,
    this.lng,
    this.city,
    this.completedBookings = 0,
    this.serviceIds = const [],
    this.hourlyRate,
  });
}
