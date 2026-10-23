import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';

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
    return const SizedBox(
      height: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerCard(height: 176, radius: 16),
          SizedBox(height: 12),
          ShimmerCard(width: 180, height: 14, radius: 7),
          SizedBox(height: 8),
          ShimmerCard(width: 140, height: 12, radius: 6),
          SizedBox(height: 12),
          ShimmerCard(width: double.infinity, height: 40, radius: 12),
        ],
      ),
    );
  }
}
