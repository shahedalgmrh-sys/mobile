/// UI-layer review view model (presentation) — see lib/models/service.dart
/// for the boundary contract with `lib/data/models/*`.
class Review {
  final String id;
  final String bookingId;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerAvatarUrl;
  final String providerId;
  final double overall;
  final double? quality;
  final double? punctuality;
  final double? professionalism;
  final String? comment;
  final List<String>? photoUrls;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.bookingId,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerAvatarUrl,
    required this.providerId,
    required this.overall,
    this.quality,
    this.punctuality,
    this.professionalism,
    this.comment,
    this.photoUrls,
    required this.createdAt,
  });

  String get relativeDate {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inDays >= 30) {
      return '${(diff.inDays / 30).floor()} شهر';
    } else if (diff.inDays >= 7) {
      return '${(diff.inDays / 7).floor()} أسبوع';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays} يوم';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} ساعة';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
