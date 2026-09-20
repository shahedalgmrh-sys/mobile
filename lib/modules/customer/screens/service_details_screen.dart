import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/widgets/review_card.dart';
import '../../../shared/widgets/provider_mini_card.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import '../../../models/service.dart';
import '../../../models/provider.dart';
import '../../../models/review.dart';
import '../../../shared/theme/sahel_colors.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final String slug;

  const ServiceDetailsScreen({
    super.key,
    required this.slug,
  });

  @override
  Widget build(BuildContext context) {
    final demo = Service(
      id: slug,
      slug: slug,
      titleAr: 'تنظيف المنازل الشامل',
      titleEn: 'Full Home Cleaning',
      basePrice: 1500,
      currencyCode: 'yer',
      ratingAvg: 4.8,
      reviewsCount: 124,
      categoryId: 'cat1',
      descriptionAr: 'خدمة تنظيف شامل للمنزل يتضمن غرف النوم، الصالة، المطبخ والحمامات مع فرش وتنظيف متخصص.',
    );
    final prov = ProviderModel(
      id: 'p1',
      userId: 'u1',
      businessName: 'فريق ساحل للتنظيف',
      ratingAvg: 4.9,
      totalReviews: 312,
      isVerified: true,
    );
    final review = Review(
      id: 'r1',
      bookingId: 'b1',
      reviewerId: 'u2',
      reviewerName: 'خالد عبدالله',
      providerId: 'p1',
      overall: 5,
      comment: 'خدمة ممتازة وفريق محترف، أنصح بهم بشدة.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: SahelColors.primary50,
                child: const Icon(Icons.cleaning_services, size: 80, color: SahelColors.primary300),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    demo.titleAr,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: SahelColors.slate900),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: SahelColors.amber500),
                      const SizedBox(width: 4),
                      Text('${demo.ratingAvg} (${demo.reviewsCount} تقييم)',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    demo.descriptionAr ?? '',
                    style: const TextStyle(color: SahelColors.muted, fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  const Text('المزود', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => context.push('/providers/${prov.id}'),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: SahelColors.slate200),
                      ),
                      child: ProviderMiniCard(p: prov),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('التقييمات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ReviewCard(r: review),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('السعر', style: TextStyle(color: SahelColors.muted, fontSize: 12)),
                  Text(
                    '${demo.basePrice.toStringAsFixed(0)} ﷼',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: SahelColors.primary700),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SahelButton(
                  label: 'احجز هذه الخدمة',
                  variant: SahelButtonVariant.gradient,
                  prefixIcon: Icons.event,
                  onPressed: () => context.push('/bookings/new'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
