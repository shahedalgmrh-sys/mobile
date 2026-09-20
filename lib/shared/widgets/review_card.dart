import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/review.dart';
import '../theme/sahel_colors.dart';
import '../theme/sahel_radii.dart';

class ReviewCard extends StatelessWidget {
  final Review r;

  const ReviewCard({
    super.key,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    const xs = BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 4,
      offset: Offset(0, 1),
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SahelRadii.md),
        boxShadow: const [xs],
        border: Border.all(color: SahelColors.slate200, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: SahelColors.primary100,
                child: r.reviewerAvatarUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: r.reviewerAvatarUrl!,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _initials(),
                        ),
                      )
                    : _initials(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.reviewerName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: SahelColors.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          r.relativeDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: SahelColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          return Icon(
                            i < r.overall.round()
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: SahelColors.amber500,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          r.overall.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: SahelColors.text,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (r.comment != null) ...[
            const SizedBox(height: 8),
            Text(
              r.comment!,
              style: const TextStyle(
                fontSize: 14,
                color: SahelColors.muted,
                height: 1.5,
              ),
            ),
          ],
          if (r.photoUrls != null && r.photoUrls!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: r.photoUrls!.map((url) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(SahelRadii.sm),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: SahelColors.slate200,
                      child:
                          const Icon(Icons.image_not_supported, size: 20, color: SahelColors.muted),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _initials() {
    final name = r.reviewerName.trim();
    final initial = name.isNotEmpty ? name[0] : '?';
    return Text(
      initial,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: SahelColors.primary700,
      ),
    );
  }
}
