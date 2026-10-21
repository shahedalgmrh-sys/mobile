import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/data/repositories/catalog_repository.dart';
import 'package:saber_flutter/models/provider.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/providers/location_provider.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/shared/widgets/category_tile.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/shared/widgets/service_card.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _categoryStyles = [
    (Icons.cleaning_services, SahelColors.primary700, SahelColors.primarySurface),
    (Icons.plumbing, SahelColors.primary600, SahelColors.secondaryContainer),
    (Icons.bolt, SahelColors.amber800, SahelColors.tertiaryFixed),
    (Icons.ac_unit, SahelColors.primary, SahelColors.surfaceInset),
    (Icons.dry_cleaning, SahelColors.primary700, SahelColors.primarySurface),
    (Icons.pest_control, SahelColors.danger, SahelColors.errorContainer),
    (Icons.format_paint, SahelColors.violet, SahelColors.violetSoft),
    (Icons.home_repair_service, SahelColors.info, SahelColors.infoSoft),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(homeFeedProvider);
    final auth = ref.watch(authNotifierProvider);
    final unread = ref.watch(unreadNotificationsProvider).valueOrNull;
    final city = auth.user?['city']?.toString();

    return Scaffold(
      backgroundColor: SahelColors.bg,
      body: Column(
        children: [
          _HomeHeader(
            city: (city != null && city.isNotEmpty) ? city : 'حدد موقعك',
            hasUnread: (unread?.length ?? 0) > 0,
          ),
          Expanded(
            child: feed.when(
              loading: () => const _HomeLoading(),
              error: (e, _) => _HomeError(
                onRetry: () => ref.invalidate(homeFeedProvider),
              ),
              data: (data) => RefreshIndicator(
                color: SahelColors.primary,
                onRefresh: () async => ref.invalidate(homeFeedProvider),
                child: _HomeContent(data: data),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.city, required this.hasUnread});

  final String city;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SahelColors.surface,
        border: Border(
          bottom: BorderSide(color: SahelColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: SahelColors.shadowSm,
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      gradient: SahelColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'س',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ساحل',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: SahelColors.primary,
                    ),
                  ),
                  const Spacer(),
                  _LocationPill(city: city),
                  const Spacer(),
                  _IconCircle(
                    icon: Icons.notifications_none,
                    showDot: hasUnread,
                    onTap: () => context.push('/notifications'),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: SahelColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push('/search'),
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: SahelColors.surface,
                          borderRadius: SahelRadii.pillRadius,
                          border: Border.all(color: SahelColors.border),
                          boxShadow: SahelElevations.xs,
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search,
                                size: 22, color: SahelColors.textMuted),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'ابحث عن خدمة، صيانة، تنظيف…',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: SahelColors.textSoft,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _IconCircle(
                    icon: Icons.tune,
                    color: SahelColors.primary,
                    onTap: () => context.push('/search'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationPill extends ConsumerWidget {
  const _LocationPill({required this.city});

  final String city;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(appLocationProvider).valueOrNull;
    final label = location?.city ?? city;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: SahelRadii.pillRadius,
        onTap: () async {
          try {
            await ref
                .read(appLocationProvider.notifier)
                .useCurrentLocation(forceRefresh: true);
          } catch (error) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  error.toString().replaceFirst('Exception: ', ''),
                ),
              ),
            );
          }
          if (!context.mounted) return;
          context.push('/search', extra: {'nearby': true});
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 190),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: SahelColors.surfaceInset,
            borderRadius: SahelRadii.pillRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, size: 16, color: SahelColors.primary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: SahelColors.text,
                  ),
                ),
              ),
              const Icon(
                Icons.expand_more,
                size: 16,
                color: SahelColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({
    required this.icon,
    this.onTap,
    this.color = SahelColors.text,
    this.showDot = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SahelColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 22, color: color),
              if (showDot)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: SahelColors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(color: SahelColors.surface, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.data});

  final HomeFeed data;

  @override
  Widget build(BuildContext context) {
    final popular = data.popularServices.isNotEmpty
        ? data.popularServices
        : data.featuredServices;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _PromoHero(offer: data.offers.isNotEmpty ? data.offers.first : null),
        const SizedBox(height: 24),
        _CategoriesSection(categories: data.categories),
        if (popular.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'الخدمات الأكثر حجزاً هذا الشهر',
            subtitle: 'هذه الخدمات يثق بها عملاؤنا أكثر من غيرها',
            actionLabel: 'عرض الكل',
            onAction: () => context.push('/search'),
          ),
          const SizedBox(height: 12),
          for (final service in popular) ...[
            ServiceCard(
              service: service,
              categoryLabel: _categoryName(service.categoryId),
              onTap: () => context.push(
                '/home/services/${service.slug.isNotEmpty ? service.slug : service.id}',
                extra: service,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
        if (data.featuredProviders.isNotEmpty) ...[
          const SizedBox(height: 8),
          _SectionHeader(
            title: 'تعرف على أفضل المزوّدين',
            subtitle: 'مزوّدون معتمدون بتقييمات عالية وخدمة موثوقة',
            actionLabel: 'كل المزوّدين',
            onAction: () => context.push('/search'),
          ),
          const SizedBox(height: 12),
          for (final provider in data.featuredProviders) ...[
            _ProviderCard(provider: provider),
            const SizedBox(height: 16),
          ],
        ],
        const SizedBox(height: 8),
        const _AssuranceStrip(),
      ],
    );
  }

  String? _categoryName(String id) {
    for (final c in data.categories) {
      if (c.id == id) return c.name;
    }
    return null;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: SahelTextStyles.headlineSm),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: SahelTextStyles.caption),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: SahelColors.primary,
                  ),
                ),
                const Icon(Icons.arrow_back,
                    size: 16, color: SahelColors.primary),
              ],
            ),
          ),
      ],
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection({required this.categories});

  final List<CategoryItem> categories;

  @override
  Widget build(BuildContext context) {
    const styles = HomeScreen._categoryStyles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'الأقسام الرئيسية',
          actionLabel: 'الكل',
          onAction: () => context.push('/search'),
        ),
        const SizedBox(height: 12),
        if (categories.isEmpty)
          const _EmptyLine(text: 'لا توجد تصنيفات متاحة حالياً')
        else
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            primary: false,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.05,
            children: [
              for (var i = 0; i < categories.length; i++)
                CategoryTile(
                  icon: styles[i % styles.length].$1,
                  label: categories[i].name,
                  color: styles[i % styles.length].$2,
                  bgColor: styles[i % styles.length].$3,
                  onTap: () =>
                      context.push('/search?category=${categories[i].id}'),
                ),
            ],
          ),
      ],
    );
  }
}

class _PromoHero extends StatelessWidget {
  const _PromoHero({this.offer});

  final OfferItem? offer;

  @override
  Widget build(BuildContext context) {
    final title = offer?.title ?? 'خصم 20% على باقات التنظيف الشامل';
    final description = offer?.description ??
        'استمتع بنظافة استثنائية لمنزلك بأعلى المعايير مع كوادر موثوقة ومضمونة.';
    final discount = offer?.discountPercent;

    return Container(
      decoration: BoxDecoration(
        gradient: SahelColors.primaryGradient,
        borderRadius: SahelRadii.mdRadius,
        boxShadow: SahelElevations.sm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: -24,
            bottom: -24,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -16,
            top: -16,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: SahelColors.secondaryContainer.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: SahelRadii.pillRadius,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome,
                              size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'عرض الموسم المميّز',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: SahelColors.tertiaryFixed,
                        borderRadius: SahelRadii.pillRadius,
                      ),
                      child: Text(
                        discount != null
                            ? 'خصم ${discount.toStringAsFixed(0)}%'
                            : 'كود: SAHEL20',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: SahelColors.onTertiaryFixed,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: SahelColors.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified,
                          size: 14, color: SahelColors.onSecondaryContainer),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'ضمان الجودة 100%',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SahelButton.whiteBgPrimaryText(
                      label: 'احجز الآن',
                      width: 120,
                      onPressed: () => context.push('/search'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({required this.provider});

  final ProviderModel provider;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SahelColors.surface,
      borderRadius: SahelRadii.mdRadius,
      child: InkWell(
        borderRadius: SahelRadii.mdRadius,
        onTap: () => context.push('/home/providers/${provider.id}'),
        child: Ink(
          decoration: BoxDecoration(
            color: SahelColors.surface,
            borderRadius: SahelRadii.mdRadius,
            border: Border.all(color: SahelColors.border),
            boxShadow: SahelElevations.xs,
          ),
          child: Column(
            children: [
              SizedBox(
                height: 96,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 80,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: SahelColors.primaryGradient,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 64,
                        height: 64,
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: SahelColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: SahelElevations.sm,
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: SahelColors.primarySurface,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.home_repair_service,
                              size: 32, color: SahelColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            provider.businessName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: SahelTextStyles.titleCard,
                          ),
                        ),
                        if (provider.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified,
                              size: 18, color: SahelColors.primary),
                        ],
                      ],
                    ),
                    if (provider.city != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        provider.city!,
                        style: SahelTextStyles.caption,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 3),
                      decoration: BoxDecoration(
                        color: SahelColors.amber50,
                        borderRadius: SahelRadii.pillRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              size: 16, color: SahelColors.amber500),
                          const SizedBox(width: 4),
                          Text(
                            provider.ratingAvg.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: SahelColors.amber800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${provider.totalReviews} تقييم)',
                            style: SahelTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: SahelColors.surfaceSubtle,
                        borderRadius: SahelRadii.mdRadius,
                      ),
                      child: Row(
                        children: [
                          _ProviderStat(
                            value: '${provider.completedBookings}',
                            label: 'حجز ناجح',
                          ),
                          _ProviderStat(
                            value: '${provider.serviceIds.length}',
                            label: 'خدمات نشطة',
                          ),
                          _ProviderStat(
                            value: provider.isOnline ? 'متاح' : 'غير متاح',
                            label: 'الحالة الآن',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SahelButton(
                      label: 'عرض الملف التعريفي',
                      variant: SahelButtonVariant.filled,
                      height: 40,
                      borderRadius: SahelRadii.pillRadius,
                      onPressed: () =>
                          context.push('/home/providers/${provider.id}'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderStat extends StatelessWidget {
  const _ProviderStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: SahelColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: SahelColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssuranceStrip extends StatelessWidget {
  const _AssuranceStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SahelColors.primarySurface,
        borderRadius: SahelRadii.mdRadius,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: SahelColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user,
                size: 22, color: SahelColors.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ضمان ساحل الماسي',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: SahelColors.primary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'تعويض كامل أو إعادة تنفيذ الخدمة مجاناً في حال عدم رضاك 100%',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: SahelColors.textMuted,
                  ),
                ),
              ],
            ),
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
        ShimmerCard(height: 170, radius: 16),
        SizedBox(height: 16),
        ShimmerCard(height: 90, radius: 12),
        SizedBox(height: 16),
        ShimmerServiceCard(),
        SizedBox(height: 16),
        ShimmerServiceCard(),
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
