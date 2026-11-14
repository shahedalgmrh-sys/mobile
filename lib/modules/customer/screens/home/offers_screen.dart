import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/data/repositories/catalog_repository.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/empty_state.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

/// Public `/offers` list. Every card renders only fields returned by the API;
/// when the API returns no offers the screen shows a real empty state.
class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});

  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Prefetches the next page once the list comes within ~320px of the end.
  void _onScroll() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    if (position.pixels < position.maxScrollExtent - 320) return;
    _loadMore();
  }

  Future<void> _loadMore() async {
    try {
      await ref.read(offersCatalogProvider.notifier).loadMore();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تحميل المزيد من العروض')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final offers = ref.watch(offersCatalogProvider);

    return Scaffold(
      backgroundColor: SahelColors.bg,
      appBar: AppBar(title: const Text('العروض')),
      body: SafeArea(
        child: offers.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ShimmerCard(height: 200),
              SizedBox(height: 12),
              ShimmerCard(height: 200),
              SizedBox(height: 12),
              ShimmerCard(height: 200),
            ],
          ),
          error: (e, _) => _OffersError(
            onRetry: () => ref.invalidate(offersCatalogProvider),
          ),
          data: (state) {
            if (state.items.isEmpty) {
              return const EmptyState(
                title: 'لا توجد عروض متاحة حالياً',
                subtitle: 'سيتم عرض العروض والخصومات الفعّالة هنا بمجرد نشرها',
                icon: Icons.local_offer_outlined,
              );
            }
            return RefreshIndicator(
              color: SahelColors.primary,
              onRefresh: () async => ref.invalidate(offersCatalogProvider),
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  for (final offer in state.items) ...[
                    _OfferCard(offer: offer),
                    const SizedBox(height: 12),
                  ],
                  _PaginationFooter(
                    isLoadingMore: state.isLoadingMore,
                    hasMore: state.hasMore,
                    onLoadMore: _loadMore,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer});

  final OfferItem offer;

  @override
  Widget build(BuildContext context) {
    final discountLabel = _discountLabel(offer);
    final validity = _validityLabel(offer);
    final hasImage = offer.image != null && offer.image!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: SahelColors.surface,
        borderRadius: SahelRadii.mdRadius,
        border: Border.all(color: SahelColors.border),
        boxShadow: SahelElevations.xs,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            Stack(
              children: [
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: offer.image!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const _OfferImageFallback(),
                    placeholder: (_, __) =>
                        const ShimmerCard(height: 160, radius: 0),
                  ),
                ),
                if (discountLabel != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _DiscountBadge(label: discountLabel),
                  ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        offer.title,
                        style: SahelTextStyles.titleCard,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!hasImage && discountLabel != null) ...[
                      const SizedBox(width: 8),
                      _DiscountBadge(label: discountLabel),
                    ],
                  ],
                ),
                if (offer.description != null &&
                    offer.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    offer.description!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: SahelTextStyles.caption.copyWith(height: 1.5),
                  ),
                ],
                if (offer.minPurchase != null ||
                    validity != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      if (offer.minPurchase != null)
                        _OfferMeta(
                          icon: Icons.shopping_bag_outlined,
                          text:
                              'الحد الأدنى للشراء: ${_formatAmount(offer.minPurchase!)}',
                        ),
                      if (validity != null)
                        _OfferMeta(
                          icon: Icons.event_available_outlined,
                          text: validity,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _discountLabel(OfferItem offer) {
    final type = (offer.discountType ?? '').toLowerCase();
    final value = offer.discountValue;
    if (type == 'percentage' || type == 'percent') {
      final percent = offer.discountPercent ?? value;
      if (percent != null && percent > 0) {
        return '-${_formatAmount(percent)}%';
      }
      return null;
    }
    if (type == 'fixed' || type == 'amount') {
      if (value != null && value > 0) {
        return 'خصم ${_formatAmount(value)}';
      }
      return null;
    }
    final percent = offer.discountPercent;
    if (percent != null && percent > 0) {
      return '-${_formatAmount(percent)}%';
    }
    return null;
  }

  String? _validityLabel(OfferItem offer) {
    final start = _shortDate(offer.startDate);
    final end = _shortDate(offer.endDate);
    if (start != null && end != null) return 'من $start إلى $end';
    if (end != null) return 'حتى $end';
    if (start != null) return 'ابتداءً من $start';
    return null;
  }

  String? _shortDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '${parsed.year}-$month-$day';
  }

  String _formatAmount(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: const BoxDecoration(
        color: SahelColors.red600,
        borderRadius: SahelRadii.pillRadius,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: SahelColors.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _OfferMeta extends StatelessWidget {
  const _OfferMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: SahelColors.primary600),
        const SizedBox(width: 4),
        Text(text, style: SahelTextStyles.caption),
      ],
    );
  }
}

class _OfferImageFallback extends StatelessWidget {
  const _OfferImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SahelColors.surfaceInset,
      child: const Center(
        child: Icon(
          Icons.local_offer_outlined,
          size: 48,
          color: SahelColors.primary200,
        ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.isLoadingMore,
    required this.hasMore,
    required this.onLoadMore,
  });

  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (!hasMore) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: isLoadingMore
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : TextButton.icon(
                onPressed: onLoadMore,
                icon: const Icon(Icons.expand_more),
                label: const Text('تحميل المزيد'),
              ),
      ),
    );
  }
}

class _OffersError extends StatelessWidget {
  const _OffersError({required this.onRetry});

  final VoidCallback onRetry;

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
            'تعذر تحميل العروض',
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
