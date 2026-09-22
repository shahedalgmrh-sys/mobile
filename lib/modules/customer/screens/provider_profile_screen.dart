import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/data/repositories/catalog_repository.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import '../../../models/review.dart';
import '../../../shared/widgets/provider_mini_card.dart';
import '../../../shared/widgets/review_card.dart';
import 'package:saber_flutter/shared/widgets/service_card.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';
import '../../../shared/theme/sahel_colors.dart';

class ProviderProfileScreen extends ConsumerWidget {
  final String id;

  const ProviderProfileScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile =
        ref.watch(publicProviderProfileProvider(int.tryParse(id) ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: Text(profile.valueOrNull == null
            ? 'ملف المزود'
            : str(asMap(profile.valueOrNull!['provider'])['business_name'],
                'ملف المزود')),
      ),
      body: SafeArea(
        child: profile.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ShimmerCard(height: 120),
              SizedBox(height: 16),
              ShimmerCard(height: 60),
              SizedBox(height: 24),
              ShimmerCard(height: 180),
            ],
          ),
          error: (e, _) => Center(
            child: TextButton.icon(
              onPressed: () => ref.invalidate(
                  publicProviderProfileProvider(int.tryParse(id) ?? 0)),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ),
          data: (data) {
            final p =
                providerFromJson(asMap(data['provider']));
            final services =
                dataList(data['services']).map(serviceFromJson).toList();
            final reviews = dataList(data['reviews']).map(_reviewFromJson).toList();

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(
                  publicProviderProfileProvider(int.tryParse(id) ?? 0)),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ProviderMiniCard(p: p),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _stat(
                              '${p.completedBookings}+', 'حجز منجز')),
                      Expanded(child: _stat('${p.ratingAvg}', 'التقييم')),
                      Expanded(child: _stat(p.city ?? '—', 'المدينة')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('الخدمات المقدمة',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  if (services.isEmpty)
                    const Text('لا توجد خدمات منشورة حالياً',
                        style: TextStyle(color: SahelColors.muted))
                  else
                    for (final s in services)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ServiceCard(
                          service: s,
                          onTap: () => context.push(
                              '/home/services/${s.slug.isNotEmpty ? s.slug : s.id}',
                              extra: s),
                        ),
                      ),
                  const SizedBox(height: 24),
                  const Text('أحدث التقييمات',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  if (reviews.isEmpty)
                    const Text('لا توجد تقييمات بعد',
                        style: TextStyle(color: SahelColors.muted))
                  else
                    for (final r in reviews)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ReviewCard(r: r),
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Review _reviewFromJson(Map<String, dynamic> j) {
    final customer = asMap(j['customer']);
    final reviewer =
        asMap(j['reviewer'] ?? customer['user'] ?? j['user']);
    return Review(
      id: str(j['id']),
      bookingId: str(j['booking_id']),
      reviewerId: str(reviewer['id'] ?? customer['id']),
      reviewerName: str(reviewer['name'] ?? j['reviewer_name'], 'عميل'),
      reviewerAvatarUrl: strOrNull(reviewer['avatar'] ?? reviewer['avatar_url']),
      providerId: id,
      overall: toDouble(j['rating'] ?? j['overall']),
      comment: strOrNull(j['comment'] ?? j['body']),
      createdAt: toDate(j['created_at']) ?? DateTime.now(),
    );
  }

  Widget _stat(String v, String l) {
    return Column(
      children: [
        Text(v,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: SahelColors.primary700)),
        const SizedBox(height: 4),
        Text(l,
            style: const TextStyle(fontSize: 11, color: SahelColors.muted)),
      ],
    );
  }
}
