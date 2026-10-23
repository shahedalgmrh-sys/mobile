import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';

class MyReviewsScreen extends ConsumerWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(customerReviewsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تقييماتي')),
      body: SafeArea(
        child: reviews.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ShimmerCard(height: 90),
              SizedBox(height: 10),
              ShimmerCard(height: 90),
            ],
          ),
          error: (e, _) => Center(
            child: TextButton.icon(
              onPressed: () => ref.invalidate(customerReviewsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ),
          data: (items) => items.isEmpty
              ? const Center(
                  child: Text('لا توجد تقييمات بعد',
                      style: TextStyle(color: SahelColors.muted)))
              : RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(customerReviewsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (ctx, i) {
                      final r = items[i];
                      final rating = toDouble(r['rating'] ?? r['overall']);
                      final comment = str(r['comment'] ?? r['body']);
                      final booking = asMap(r['booking']);
                      final service = asMap(r['service'] ?? booking['service']);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                        str(service['name'] ??
                                            service['title'],
                                            'خدمة'),
                                        style: const TextStyle(
                                            fontWeight:
                                                FontWeight.w700)),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          size: 16,
                                          color: SahelColors.amber500),
                                      const SizedBox(width: 4),
                                      Text(rating.toStringAsFixed(1),
                                          style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.w800)),
                                    ],
                                  ),
                                ],
                              ),
                              if (comment.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(comment,
                                    style: const TextStyle(
                                        color: SahelColors.muted,
                                        fontSize: 13,
                                        height: 1.4)),
                              ],
                              const SizedBox(height: 6),
                              Text(
                                  str(r['created_at'])
                                      .split('T')
                                      .first,
                                  style: const TextStyle(
                                      color: SahelColors.muted,
                                      fontSize: 11)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
