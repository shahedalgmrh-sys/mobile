import 'package:flutter/material.dart';
import '../../../shared/widgets/provider_mini_card.dart';
import '../../../shared/widgets/review_card.dart';
import 'package:saber_flutter/shared/widgets/service_card.dart';
import '../../../models/provider.dart';
import '../../../models/review.dart';
import '../../../models/service.dart';
import '../../../shared/theme/sahel_colors.dart';

class ProviderProfileScreen extends StatelessWidget {
  final String id;

  const ProviderProfileScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final p = ProviderModel(
      id: id,
      userId: 'u$id',
      businessName: 'فريق ساحل للتنظيف',
      ratingAvg: 4.9,
      totalReviews: 312,
      isVerified: true,
      completedBookings: 480,
      city: 'صنعاء',
    );
    final s = Service(
      id: 's1',
      slug: 'deep-clean',
      titleAr: 'تنظيف عميق',
      titleEn: 'Deep Clean',
      basePrice: 2500,
      currencyCode: 'yer',
      ratingAvg: 4.9,
      reviewsCount: 210,
      categoryId: 'c1',
    );
    final r = Review(
      id: 'r1',
      bookingId: 'b1',
      reviewerId: 'u2',
      reviewerName: 'خالد عبدالله',
      providerId: id,
      overall: 5,
      comment: 'فريق ممتاز واحترافي.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    );

    return Scaffold(
      appBar: AppBar(title: Text(p.businessName)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProviderMiniCard(p: p),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _stat('${p.completedBookings}+', 'حجز منجز'),
                ),
                Expanded(
                  child: _stat('${p.ratingAvg}', 'التقييم'),
                ),
                Expanded(
                  child: _stat(p.city ?? '—', 'المدينة'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('الخدمات المقدمة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ServiceCard(service: s, onTap: () {}, onBookNow: () {}),
            const SizedBox(height: 24),
            const Text('أحدث التقييمات',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ReviewCard(r: r),
          ],
        ),
      ),
    );
  }

  Widget _stat(String v, String l) {
    return Column(
      children: [
        Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: SahelColors.primary700)),
        const SizedBox(height: 4),
        Text(l, style: const TextStyle(fontSize: 11, color: SahelColors.muted)),
      ],
    );
  }
}
