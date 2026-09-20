import 'package:json_annotation/json_annotation.dart';

part 'provider_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Provider {
  final int userId;
  final String businessName;
  final String? bioAr;
  final String? bioEn;
  final double ratingAvg;
  final int totalReviews;
  final int completedBookings;
  final bool isVerified;
  final String? licenseNumber;
  final String? coverPhoto;
  final List<int> serviceAreaCityIds;
  final Map<String, dynamic>? workingHours;
  final List<String> portfolioUrls;
  final double walletBalance;
  final double totalEarnings;
  final DateTime? verificationDate;

  const Provider({
    required this.userId,
    required this.businessName,
    this.bioAr,
    this.bioEn,
    required this.ratingAvg,
    required this.totalReviews,
    required this.completedBookings,
    required this.isVerified,
    this.licenseNumber,
    this.coverPhoto,
    required this.serviceAreaCityIds,
    this.workingHours,
    required this.portfolioUrls,
    required this.walletBalance,
    required this.totalEarnings,
    this.verificationDate,
  });

  factory Provider.fromJson(Map<String, dynamic> json) =>
      _$ProviderFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderToJson(this);

  Provider copyWith({
    int? userId,
    String? businessName,
    String? bioAr,
    String? bioEn,
    double? ratingAvg,
    int? totalReviews,
    int? completedBookings,
    bool? isVerified,
    String? licenseNumber,
    String? coverPhoto,
    List<int>? serviceAreaCityIds,
    Map<String, dynamic>? workingHours,
    List<String>? portfolioUrls,
    double? walletBalance,
    double? totalEarnings,
    DateTime? verificationDate,
  }) {
    return Provider(
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      bioAr: bioAr ?? this.bioAr,
      bioEn: bioEn ?? this.bioEn,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      totalReviews: totalReviews ?? this.totalReviews,
      completedBookings: completedBookings ?? this.completedBookings,
      isVerified: isVerified ?? this.isVerified,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      serviceAreaCityIds: serviceAreaCityIds ?? this.serviceAreaCityIds,
      workingHours: workingHours ?? this.workingHours,
      portfolioUrls: portfolioUrls ?? this.portfolioUrls,
      walletBalance: walletBalance ?? this.walletBalance,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      verificationDate: verificationDate ?? this.verificationDate,
    );
  }
}
