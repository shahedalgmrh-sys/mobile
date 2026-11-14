import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/data/repositories/catalog_repository.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';

import '../../../models/review.dart';
import '../../../shared/widgets/provider_mini_card.dart';
import '../../../shared/widgets/review_card.dart';

import 'package:saber_flutter/shared/widgets/favorite_toggle_button.dart';
import 'package:saber_flutter/shared/widgets/service_card.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';

class ProviderProfileScreen extends ConsumerWidget {
  final String id;

  const ProviderProfileScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(publicProviderProfileProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          profile.valueOrNull == null
              ? 'ملف المزود'
              : str(
                  asMap(profile.valueOrNull!['provider'])['business_name'],
                  'ملف المزود',
                ),
        ),
        actions: [FavoriteToggleButton(id: id, isProvider: true)],
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
              onPressed: () =>
                  ref.invalidate(publicProviderProfileProvider(id)),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ),
          data: (data) {
            final p = providerFromJson(asMap(data['provider']));
            final services = dataList(data['services'])
                .map(serviceFromJson)
                .toList();
            final portfolios = dataList(data['portfolios']);
            final reviews = dataList(data['reviews'])
                .map(_reviewFromJson)
                .toList();

            return RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(publicProviderProfileProvider(id)),
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
                      Expanded(child: _stat('${p.ratingAvg}', 'التقييم')),
                      Expanded(child: _stat(p.city ?? '—', 'المدينة')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'الخدمات المقدمة',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  if (services.isEmpty)
                    const Text(
                      'لا توجد خدمات منشورة حالياً',
                      style: TextStyle(color: SahelColors.muted),
                    )
                  else
                    for (final s in services)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ServiceCard(
                          service: s,
                          onTap: () => context.push(
                            '/home/services/${s.slug.isNotEmpty ? s.slug : s.id}',
                            extra: s,
                          ),
                        ),
                      ),
                  const SizedBox(height: 24),
                  if (portfolios.isNotEmpty) ...[
                    const Text(
                      'معرض الأعمال',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 168,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: portfolios.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => _PortfolioCard(
                          portfolio: portfolios[i],
                          onTap: () => _openPortfolio(context, portfolios[i]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Text(
                    'أحدث التقييمات',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  if (reviews.isEmpty)
                    const Text(
                      'لا توجد تقييمات بعد',
                      style: TextStyle(color: SahelColors.muted),
                    )
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
    final reviewer = asMap(j['reviewer'] ?? customer['user'] ?? j['user']);
    return Review(
      id: str(j['id']),
      bookingId: str(j['booking_id']),
      reviewerId: str(reviewer['id'] ?? customer['id']),
      reviewerName: str(reviewer['name'] ?? j['reviewer_name'], 'عميل'),
      reviewerAvatarUrl: strOrNull(
        reviewer['avatar'] ?? reviewer['avatar_url'],
      ),
      providerId: id,
      overall: toDouble(j['rating'] ?? j['overall']),
      comment: strOrNull(j['review'] ?? j['comment'] ?? j['body']),
      createdAt: toDate(j['created_at']) ?? DateTime.now(),
    );
  }

  Widget _stat(String v, String l) {
    return Column(
      children: [
        Text(
          v,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: SahelColors.primary700,
          ),
        ),
        const SizedBox(height: 4),
        Text(l, style: const TextStyle(fontSize: 11, color: SahelColors.muted)),
      ],
    );
  }
}

/// First real image exposed by a portfolio item (`image`, else `gallery[0]`).
String? _portfolioImage(Map<String, dynamic> p) {
  final image = str(p['image']);
  if (image.isNotEmpty) return image;
  final gallery = p['gallery'];
  if (gallery is List && gallery.isNotEmpty) {
    final first = str(gallery.first);
    if (first.isNotEmpty) return first;
  }
  return null;
}

void _openPortfolio(BuildContext context, Map<String, dynamic> p) {
  final title = str(p['title'], 'عمل من المعرض');
  final image = _portfolioImage(p);
  final description = str(p['description']);
  final category = str(p['category']);
  final location = str(p['location']);
  final completion = str(p['completion_date']);
  final budget = str(p['budget']);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: SahelColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: SahelColors.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (image != null) ...[
                ClipRRect(
                  borderRadius: SahelRadii.mdRadius,
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          const _PortfolioImageFallback(),
                      placeholder: (_, __) =>
                          const ShimmerCard(height: 200, radius: 0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(title, style: SahelTextStyles.headlineSm),
              if (category.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: const BoxDecoration(
                    color: SahelColors.primarySurface,
                    borderRadius: SahelRadii.pillRadius,
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: SahelColors.primary700,
                    ),
                  ),
                ),
              ],
              if (description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  description,
                  style: SahelTextStyles.caption.copyWith(height: 1.6),
                ),
              ],
              if (location.isNotEmpty ||
                  completion.isNotEmpty ||
                  budget.isNotEmpty) ...[
                const SizedBox(height: 16),
                if (location.isNotEmpty)
                  _PortfolioDetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'الموقع',
                    value: location,
                  ),
                if (completion.isNotEmpty)
                  _PortfolioDetailRow(
                    icon: Icons.event_outlined,
                    label: 'تاريخ الإنجاز',
                    value: completion,
                  ),
                if (budget.isNotEmpty)
                  _PortfolioDetailRow(
                    icon: Icons.payments_outlined,
                    label: 'الميزانية',
                    value: budget,
                  ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('إغلاق'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard({required this.portfolio, required this.onTap});

  final Map<String, dynamic> portfolio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final image = _portfolioImage(portfolio);
    final title = str(portfolio['title'], 'عمل من المعرض');
    final category = str(portfolio['category']);

    return SizedBox(
      width: 220,
      child: Material(
        color: SahelColors.surface,
        borderRadius: SahelRadii.mdRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: SahelRadii.mdRadius,
          child: Ink(
            decoration: BoxDecoration(
              color: SahelColors.surface,
              borderRadius: SahelRadii.mdRadius,
              border: Border.all(color: SahelColors.border),
              boxShadow: SahelElevations.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: image != null
                        ? CachedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorWidget: (_, __, ___) =>
                                const _PortfolioImageFallback(),
                            placeholder: (_, __) => const ShimmerCard(
                              height: double.infinity,
                              radius: 0,
                            ),
                          )
                        : const _PortfolioImageFallback(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SahelTextStyles.titleCard,
                      ),
                      if (category.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SahelTextStyles.caption,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PortfolioImageFallback extends StatelessWidget {
  const _PortfolioImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SahelColors.surfaceInset,
      child: const Center(
        child: Icon(
          Icons.photo_library_outlined,
          size: 36,
          color: SahelColors.primary200,
        ),
      ),
    );
  }
}

class _PortfolioDetailRow extends StatelessWidget {
  const _PortfolioDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: SahelColors.primary600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: SahelColors.textMuted,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: SahelColors.text),
            ),
          ),
        ],
      ),
    );
  }
}
