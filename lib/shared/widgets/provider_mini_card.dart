import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/provider.dart';
import '../theme/sahel_colors.dart';
import 'status_pill.dart';

class ProviderMiniCard extends StatelessWidget {
  final ProviderModel? p;
  final String? businessName;
  final String? avatarUrl;
  final bool? isVerified;
  final double? ratingAvg;
  final int? totalReviews;

  const ProviderMiniCard({
    super.key,
    this.p,
    this.businessName,
    this.avatarUrl,
    this.isVerified,
    this.ratingAvg,
    this.totalReviews,
  });

  String get _businessName => (p?.businessName ?? businessName) ?? 'فني غير مسمى';
  String? get _avatarUrl => p?.avatarUrl ?? avatarUrl;
  bool get _isVerified => (p?.isVerified ?? isVerified) ?? false;
  double get _ratingAvg => (p?.ratingAvg ?? ratingAvg) ?? 4.8;
  int get _totalReviews => (p?.totalReviews ?? totalReviews) ?? 127;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: SahelColors.primary100,
          child: _avatarUrl != null
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: _avatarUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _initialsAvatar(),
                  ),
                )
              : _initialsAvatar(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _businessName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: SahelColors.text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _isVerified
                      ? StatusPill.verifiedTeal(text: 'موثق')
                      : StatusPill.slate(text: 'قيد المراجعة'),
                  const SizedBox(width: 8),
                  const Icon(Icons.star, size: 14, color: SahelColors.amber500),
                  const SizedBox(width: 2),
                  Text(
                    '${_ratingAvg.toStringAsFixed(1)}  ($_totalReviews)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: SahelColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _initialsAvatar() {
    final name = _businessName.trim();
    final initial = name.isNotEmpty ? name[0] : '?';
    return Text(
      initial,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: SahelColors.primary700,
      ),
    );
  }
}
