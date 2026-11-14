import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/favorite_toggle_button.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

import '../../../models/service.dart';

import 'package:saber_flutter/app/theme/sahel_colors.dart';

class ServiceDetailsScreen extends ConsumerWidget {
  final String slug;
  final Service? service;

  const ServiceDetailsScreen({super.key, required this.slug, this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Prefer the Service passed via route extra; otherwise resolve from
    // the public services list by slug or id.
    Service? s = service;
    AsyncValue<List<dynamic>>? listAsync;
    if (s == null) {
      listAsync = ref.watch(
        servicesProvider((q: null, categoryId: null, sort: null)),
      );
      final list = listAsync?.valueOrNull;
      if (list != null) {
        for (final item in list) {
          if (item is Service && (item.slug == slug || item.id == slug)) {
            s = item;
            break;
          }
        }
      }
    }

    if (s == null && listAsync != null) {
      return Scaffold(
        appBar: AppBar(),
        body: listAsync.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ShimmerCard(height: 220),
              SizedBox(height: 16),
              ShimmerCard(height: 140),
            ],
          ),
          error: (e, _) => Center(
            child: TextButton.icon(
              onPressed: () => ref.invalidate(servicesProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ),
          data: (_) => const Center(
            child: Text(
              'الخدمة غير موجودة',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: SahelColors.muted,
              ),
            ),
          ),
        ),
      );
    }

    final svc = s!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: FavoriteToggleButton(
                  id: svc.id,
                  backgroundColor: SahelColors.surface,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: svc.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: svc.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _imgPlaceholder(),
                    )
                  : _imgPlaceholder(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    svc.titleAr,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: SahelColors.slate900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: SahelColors.amber500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${svc.ratingAvg.toStringAsFixed(1)} (${svc.reviewsCount} تقييم)',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  if (svc.descriptionAr != null &&
                      svc.descriptionAr!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      svc.descriptionAr!,
                      style: const TextStyle(
                        color: SahelColors.muted,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                  if (svc.durationMinutes != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: SahelColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'المدة التقريبية: ${svc.durationMinutes} دقيقة',
                          style: const TextStyle(
                            color: SahelColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: SahelColors.surface,
          boxShadow: [
            BoxShadow(
              color: SahelColors.shadowSm,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'السعر',
                    style: TextStyle(color: SahelColors.muted, fontSize: 12),
                  ),
                  Text(
                    '${svc.basePrice.toStringAsFixed(0)} ${svc.currencyCode.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: SahelColors.primary700,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SahelButton(
                  label: svc.isAvailable
                      ? 'احجز هذه الخدمة'
                      : 'غير متاحة حالياً',
                  variant: SahelButtonVariant.gradient,
                  prefixIcon: svc.isAvailable ? Icons.event : Icons.block,
                  onPressed: svc.isAvailable
                      ? () => context.push(
                          '/bookings/new?service_id=${svc.id}',
                          extra: svc,
                        )
                      : () {
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'هذه الخدمة غير متاحة للحجز في الوقت الحالي',
                                ),
                                backgroundColor: SahelColors.danger,
                              ),
                            );
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
    color: SahelColors.primary50,
    child: const Icon(
      Icons.home_repair_service,
      size: 80,
      color: SahelColors.primary300,
    ),
  );
}
