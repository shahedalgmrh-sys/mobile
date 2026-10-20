import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/service.dart';
import '../theme/sahel_colors.dart';
import '../theme/sahel_theme.dart';
import 'sahel_button.dart';

/// Base white card plane: hairline border + ultra-subtle shadow, per the
/// design system's "First Tier" elevation.
class SahelCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final BoxShadow? shadow;
  final Color? color;
  final double? width;
  final VoidCallback? onTap;

  const SahelCard({
    super.key,
    required this.child,
    this.radius = 16,
    this.shadow,
    this.color,
    this.width,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return Material(
      color: color ?? SahelColors.surface,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Ink(
          width: width,
          decoration: BoxDecoration(
            color: color ?? SahelColors.surface,
            borderRadius: borderRadius,
            border: Border.all(color: SahelColors.border),
            boxShadow: shadow != null ? [shadow!] : SahelElevations.xs,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Service card mirroring the Stitch listing card: media with a category
/// eyebrow and wishlist heart, provider meta with rating pill, title, spec
/// row, and a full-bleed pricing/booking ribbon.
class ServiceCard extends StatelessWidget {
  final Service? service;
  final VoidCallback? onTap;
  final VoidCallback? onBookNow;
  final String? title;
  final double? price;
  final double? originalPrice;
  final IconData? icon;
  final double? rating;
  final int? reviews;
  final String? providerName;
  final String? categoryLabel;
  final String? durationLabel;
  final String? specLabel;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  const ServiceCard({
    super.key,
    this.service,
    this.onTap,
    this.onBookNow,
    this.title,
    this.price,
    this.originalPrice,
    this.icon,
    this.rating,
    this.reviews,
    this.providerName,
    this.categoryLabel,
    this.durationLabel,
    this.specLabel,
    this.isFavorite = false,
    this.onFavorite,
  });

  String get _title => (service?.titleAr ?? title) ?? 'خدمة غير مسمّاة';
  double? get _price => service?.basePrice ?? price;
  double? get _originalPrice {
    if (originalPrice != null) return originalPrice;
    if (service != null &&
        service!.discountPercent != null &&
        service!.discountPercent! > 0) {
      final denom = 1 - service!.discountPercent! / 100;
      if (denom > 0) return service!.basePrice / denom;
    }
    return null;
  }

  double? get _discountPercent =>
      service?.discountPercent ??
      ((_originalPrice != null && _price != null && _originalPrice! > 0)
          ? ((_originalPrice! - _price!) / _originalPrice! * 100)
          : null);
  double get _rating => (service?.ratingAvg ?? rating) ?? 4.8;
  int get _reviews => (service?.reviewsCount ?? reviews) ?? 0;
  String? get _imageUrl => service?.imageUrl;
  String get _currencyLabel {
    final code = (service?.currencyCode ?? 'SAR').toUpperCase();
    switch (code) {
      case 'YER':
        return 'ر.ي';
      case 'SAR':
        return 'ر.س';
      case 'USD':
        return '\$';
      default:
        return code;
    }
  }

  String? get _duration {
    if (durationLabel != null) return durationLabel;
    final minutes = service?.durationMinutes;
    if (minutes == null || minutes <= 0) return null;
    if (minutes < 60) return '$minutes دقيقة';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '$hours ساعات' : '$hours ساعة و$rest دقيقة';
  }

  /// Card title. Inside a bounded cell it is allowed to shrink so a long
  /// Arabic title can never overflow the card.
  Widget _titleText(bool bounded) {
    final text = Text(
      _title,
      style: SahelTextStyles.titleCard,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    return bounded ? Flexible(child: text) : text;
  }

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(16));
    final eyebrow = categoryLabel ?? _title;

    return Material(
      color: SahelColors.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: SahelColors.surface,
            borderRadius: radius,
            border: Border.all(color: SahelColors.border),
            boxShadow: SahelElevations.xs,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Inside a fixed-extent grid cell the middle block is allowed to
              // absorb the slack so the pricing ribbon stays glued to the
              // bottom; in an unbounded list it keeps its natural height.
              final bounded = constraints.hasBoundedHeight;
              final middle = Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: SahelColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon ?? Icons.home_repair_service,
                            size: 15,
                            color: SahelColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            providerName ?? 'مقدّم خدمة موثّق',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: SahelTextStyles.label.copyWith(
                              color: SahelColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          size: 16,
                          color: SahelColors.success,
                        ),
                        const Spacer(),
                        _RatingPill(rating: _rating, reviews: _reviews),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _titleText(bounded),
                    if (_duration != null || specLabel != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (_duration != null)
                            _Spec(icon: Icons.schedule, text: _duration!),
                          if (_duration != null && specLabel != null)
                            const SizedBox(width: 16),
                          if (specLabel != null)
                            Flexible(
                              child: _Spec(
                                icon: Icons.inventory_2,
                                text: specLabel!,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Media(
                    imageUrl: _imageUrl,
                    icon: icon,
                    eyebrow: eyebrow,
                    discountPercent: _discountPercent,
                    isFavorite: isFavorite,
                    onFavorite: onFavorite,
                  ),
                  if (bounded) Expanded(child: middle) else middle,
                  _ActionRibbon(
                    price: _price ?? 0,
                    currencyLabel: _currencyLabel,
                    originalPrice: _originalPrice,
                    onBookNow: onBookNow ?? onTap,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Media extends StatelessWidget {
  const _Media({
    this.imageUrl,
    this.icon,
    required this.eyebrow,
    this.discountPercent,
    this.isFavorite = false,
    this.onFavorite,
  });

  final String? imageUrl;
  final IconData? icon;
  final String eyebrow;
  final double? discountPercent;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = discountPercent != null && discountPercent! > 0;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      child: SizedBox(
        height: 176,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _placeholder(),
                placeholder: (_, __) => _placeholder(),
              )
            else
              _placeholder(),
            // Category eyebrow badge (inline-start / bottom).
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: SahelColors.surface.withValues(alpha: 0.92),
                  borderRadius: SahelRadii.pillRadius,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon ?? Icons.home_repair_service,
                      size: 14,
                      color: SahelColors.primary,
                    ),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: Text(
                        eyebrow,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SahelTextStyles.eyebrow,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (hasDiscount)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: SahelColors.red600,
                    borderRadius: SahelRadii.pillRadius,
                  ),
                  child: Text(
                    '-${discountPercent!.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            if (onFavorite != null)
              Positioned(
                top: 12,
                left: 12,
                child: _HeartButton(isFavorite: isFavorite, onTap: onFavorite),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: SahelColors.surfaceInset,
    child: Icon(
      icon ?? Icons.home_repair_service,
      size: 48,
      color: SahelColors.primary200,
    ),
  );
}

class _HeartButton extends StatelessWidget {
  const _HeartButton({required this.isFavorite, this.onTap});

  final bool isFavorite;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SahelColors.slate900.withValues(alpha: 0.25),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: isFavorite ? SahelColors.danger : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.rating, required this.reviews});

  final double rating;
  final int reviews;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: SahelColors.amber50,
        borderRadius: SahelRadii.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: SahelColors.amber500),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: SahelColors.amber800,
            ),
          ),
          if (reviews > 0) ...[
            const SizedBox(width: 4),
            Text(
              '($reviews)',
              style: const TextStyle(
                fontSize: 12,
                color: SahelColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: SahelColors.primary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SahelTextStyles.caption,
          ),
        ),
      ],
    );
  }
}

class _ActionRibbon extends StatelessWidget {
  const _ActionRibbon({
    required this.price,
    required this.currencyLabel,
    this.originalPrice,
    this.onBookNow,
  });

  final double price;
  final String currencyLabel;
  final double? originalPrice;
  final VoidCallback? onBookNow;

  @override
  Widget build(BuildContext context) {
    final hasOriginal = originalPrice != null && originalPrice! > price;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 240;
        final priceBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'السعر يبدأ من',
              style: TextStyle(fontSize: 12, color: SahelColors.textMuted),
            ),
            const SizedBox(height: 2),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 4,
              runSpacing: 2,
              children: [
                Text(price.toStringAsFixed(0), style: SahelTextStyles.price),
                Text(
                  currencyLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: SahelColors.primary,
                  ),
                ),
                if (hasOriginal)
                  Text(
                    originalPrice!.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 12,
                      color: SahelColors.textSoft,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ],
        );

        return Container(
          decoration: const BoxDecoration(
            color: SahelColors.surfaceSubtle,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
            border: Border(top: BorderSide(color: SahelColors.border)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    priceBlock,
                    const SizedBox(height: 10),
                    SahelButton(
                      label: 'احجز الآن',
                      variant: SahelButtonVariant.filled,
                      onPressed: onBookNow,
                      height: 40,
                      borderRadius: SahelRadii.pillRadius,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: priceBlock),
                    const SizedBox(width: 12),
                    SahelButton(
                      label: 'احجز الآن',
                      variant: SahelButtonVariant.filled,
                      onPressed: onBookNow,
                      width: 128,
                      height: 40,
                      borderRadius: SahelRadii.pillRadius,
                    ),
                  ],
                ),
        );
      },
    );
  }
}
