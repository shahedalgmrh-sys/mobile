import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/data/repositories/catalog_repository.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/category_tile.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/shared/widgets/service_card.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _categoryStyles = [
    (Icons.cleaning_services, SahelColors.primary600, SahelColors.primary50),
    (Icons.plumbing, SahelColors.info, SahelColors.infoSoft),
    (Icons.electrical_services, SahelColors.amber, SahelColors.amberSoft),
    (Icons.home_repair_service, SahelColors.violet, SahelColors.violetSoft),
    (Icons.air, SahelColors.success, SahelColors.successSoft),
    (Icons.carpenter, SahelColors.warning, SahelColors.warningSoft),
    (Icons.format_paint, SahelColors.danger, SahelColors.dangerSoft),
    (Icons.local_laundry_service, SahelColors.slate, SahelColors.surface3),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(homeFeedProvider);
    final auth = ref.watch(authNotifierProvider);
    final unread = ref.watch(unreadNotificationsProvider).valueOrNull;
    final titleMedium = Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700) ??
        const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: SahelColors.text);

    final city = auth.user?['city']?.toString();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(135 * 3.1415926535 / 180),
              colors: [Color(0xFF0F172A), Color(0xFF134E4A), Color(0xFF115E59)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          (city != null && city.isNotEmpty)
                              ? city
                              : 'حدد موقعك',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => context.push('/notifications'),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Stack(
                            children: [
                              const Icon(Icons.notifications_none,
                                  color: Colors.white, size: 28),
                              if ((unread?.length ?? 0) > 0)
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: CircleAvatar(
                                    radius: 7,
                                    backgroundColor: SahelColors.amber,
                                    child: Text(
                                      '${unread!.length > 9 ? '9+' : unread.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: SahelRadii.pillRadius,
                      boxShadow: [
                        BoxShadow(
                            color: SahelColors.shadowSm,
                            blurRadius: 4,
                            offset: const Offset(0, 1))
                      ],
                    ),
                    child: TextField(
                      readOnly: true,
                      onTap: () => context.go('/search'),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن خدمة، فني، تصنيف…',
                        hintStyle: const TextStyle(
                            color: SahelColors.textSoft, fontSize: 13),
                        prefixIcon: const Icon(Icons.search,
                            color: SahelColors.primary600),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(5),
                          child: SahelButton.amber(
                            height: 36,
                            width: 80,
                            label: 'بحث',
                            onPressed: () => context.go('/search'),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: feed.when(
        loading: () => const _HomeLoading(),
        error: (e, _) => _HomeError(
          onRetry: () => ref.invalidate(homeFeedProvider),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(homeFeedProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('تصفح حسب التصنيف', style: titleMedium),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/search'),
                    child: const Text(
                      'عرض الكل',
                      style: TextStyle(
                          color: SahelColors.primary700,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (data.categories.isEmpty)
                const _EmptyLine(text: 'لا توجد تصنيفات متاحة حالياً')
              else
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  primary: false,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    for (var i = 0; i < data.categories.length; i++)
                      CategoryTile(
                        icon: _categoryStyles[i % _categoryStyles.length].$1,
                        label: data.categories[i].name,
                        color: _categoryStyles[i % _categoryStyles.length].$2,
                        bgColor:
                            _categoryStyles[i % _categoryStyles.length].$3,
                        onTap: () => context.go('/search'),
                      ),
                  ],
                ),
              if (data.offers.isNotEmpty) ...[
                const SizedBox(height: 24),
                _OfferBanner(offer: data.offers.first),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Text('الخدمات الأعلى تقييماً', style: titleMedium),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/search'),
                    child: const Text(
                      'عرض الكل',
                      style: TextStyle(
                          color: SahelColors.primary700,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (data.popularServices.isEmpty && data.featuredServices.isEmpty)
                const _EmptyLine(text: 'لا توجد خدمات متاحة حالياً')
              else
                SizedBox(
                  height: 280,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: (data.popularServices.isNotEmpty
                            ? data.popularServices
                            : data.featuredServices)
                        .length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (ctx, i) {
                      final s = (data.popularServices.isNotEmpty
                          ? data.popularServices
                          : data.featuredServices)[i];
                      return ServiceCard(
                        service: s,
                        onTap: () => context.push(
                            '/home/services/${s.slug.isNotEmpty ? s.slug : s.id}',
                            extra: s),
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
}

class _OfferBanner extends StatelessWidget {
  final OfferItem offer;
  const _OfferBanner({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: SahelColors.warmGradient,
        borderRadius: SahelRadii.lgRadius,
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.local_offer, color: Colors.white, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (offer.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    offer.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SahelButton.whiteBgPrimaryText(
            label: 'استفد الآن',
            onPressed: () => context.go('/search'),
          ),
        ],
      ),
    );
  }
}

class _EmptyLine extends StatelessWidget {
  final String text;
  const _EmptyLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: SahelColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SizedBox(height: 8),
        ShimmerCard(height: 90),
        SizedBox(height: 16),
        ShimmerCard(height: 80),
        SizedBox(height: 16),
        ShimmerCard(height: 200),
      ],
    );
  }
}

class _HomeError extends StatelessWidget {
  final VoidCallback onRetry;
  const _HomeError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined,
              size: 56, color: SahelColors.textMuted),
          const SizedBox(height: 12),
          const Text(
            'تعذر تحميل المحتوى',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: SahelColors.textMuted),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
