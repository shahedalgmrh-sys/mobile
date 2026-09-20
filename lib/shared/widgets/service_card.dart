import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/service.dart';
import '../theme/sahel_colors.dart';
import '../theme/sahel_radii.dart';
import 'sahel_button.dart';

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
    Widget container = Container(
      width: width,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow != null ? [shadow!] : null,
        border: shadow == null
            ? Border.all(color: SahelColors.slate200, width: 1)
            : null,
      ),
      child: child,
    );
    if (onTap != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: container,
      );
    }
    return container;
  }
}

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
  double? get _discountPercent => service?.discountPercent ??
      ((_originalPrice != null && _price != null && _originalPrice! > 0)
          ? ((_originalPrice! - _price!) / _originalPrice! * 100)
          : null);
  double get _rating => (service?.ratingAvg ?? rating) ?? 4.8;
  int get _reviews => (service?.reviewsCount ?? reviews) ?? 64;
  String? get _imageUrl => service?.imageUrl;

  @override
  Widget build(BuildContext context) {
    const sm = BoxShadow(
      color: Color(0x1A0F172A),
      blurRadius: 8,
      offset: Offset(0, 2),
    );
    return SahelCard(
      radius: SahelRadii.md,
      shadow: sm,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: _imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: _imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: SahelColors.primary50,
                            child: Icon(icon ?? Icons.home_repair_service,
                                size: 48, color: SahelColors.primary300),
                          ),
                        )
                      : Container(
                          color: SahelColors.primary50,
                          child: Icon(icon ?? Icons.home_repair_service,
                              size: 48, color: SahelColors.primary300),
                        ),
                ),
              ),
              if (_discountPercent != null && _discountPercent! > 0)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: SahelColors.red600,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '-${_discountPercent!.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: SahelColors.amber500),
                    const SizedBox(width: 4),
                    Text(
                      _rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: SahelColors.text,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($_reviews)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: SahelColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: SahelColors.slate900,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${(_price ?? 0).toStringAsFixed(0)} ر.س',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: SahelColors.primary700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SahelButton.soft(
                      label: 'تفاصيل',
                      onTap: onTap,
                      width: 0,
                      height: 38,
                    ),
                    const Spacer(),
                    SahelButton(
                      label: 'احجز الآن',
                      onPressed: onBookNow,
                      variant: SahelButtonVariant.amber,
                      height: 38,
                      width: 0,
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
