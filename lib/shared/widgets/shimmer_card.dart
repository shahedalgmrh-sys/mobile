import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/sahel_colors.dart';

class ShimmerCard extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerCard({
    super.key,
    this.width = double.infinity,
    this.height = 120,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: SahelColors.surface3,
      highlightColor: SahelColors.surface2,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: SahelColors.surface,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class ShimmerServiceCard extends StatelessWidget {
  const ShimmerServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerCard(height: 140),
          const SizedBox(height: 12),
          Row(
            children: const [
              ShimmerCard(width: 180, height: 14, radius: 7),
              Spacer(),
              ShimmerCard(width: 60, height: 14, radius: 7),
            ],
          ),
          const SizedBox(height: 8),
          const ShimmerCard(width: 140, height: 12, radius: 6),
          const SizedBox(height: 16),
          const ShimmerCard(width: double.infinity, height: 38, radius: 10.5),
        ],
      ),
    );
  }
}
