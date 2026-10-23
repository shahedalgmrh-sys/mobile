import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

/// Provider reviews with reply — mirrors the web `/provider/reviews` page
/// against `/api/provider/reviews` + `/{id}/reply`.
class ProviderReviewsScreen extends ConsumerWidget {
  const ProviderReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(providerReviewsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('مراجعاتي')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(providerReviewsProvider),
        child: reviews.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ShimmerCard(height: 110),
              SizedBox(height: 12),
              ShimmerCard(height: 110),
            ],
          ),
          error: (e, _) => ListView(children: [
            const SizedBox(height: 80),
            Center(
              child: TextButton.icon(
                onPressed: () => ref.invalidate(providerReviewsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ),
          ]),
          data: (items) {
            if (items.isEmpty) {
              return ListView(children: const [
                SizedBox(height: 120),
                Center(
                  child: Text('لا توجد مراجعات بعد',
                      style: TextStyle(
                          color: SahelColors.muted,
                          fontWeight: FontWeight.w700)),
                ),
              ]);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _ReviewCard(review: items[i]),
            );
          },
        ),
      ),
    );
  }
}

class _ReviewCard extends ConsumerWidget {
  final Map<String, dynamic> review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rating = toDouble(review['rating']);
    final comment =
        str(review['comment'] ?? review['content'] ?? review['text']);
    final reply = str(review['reply'] ?? review['provider_reply']);
    final reviewer =
        str(review['customer_name'] ?? review['reviewer_name'], 'عميل');
    final service = str(asMap(review['service'])['name']);
    final date = str(
        review['date_ar'] ?? review['formatted_created_at'] ??
            review['created_at']);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SahelColors.onPrimary,
        borderRadius: SahelRadii.mdRadius,
        border: Border.all(color: SahelColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(reviewer,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 13)),
              const Spacer(),
              for (var i = 0; i < 5; i++)
                Icon(
                  Icons.star,
                  size: 15,
                  color: i < rating ? SahelColors.amber500
                      : SahelColors.slate200,
                ),
            ],
          ),
          if (service.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(service,
                  style: const TextStyle(
                      fontSize: 11, color: SahelColors.primary600)),
            ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(comment,
                style: const TextStyle(
                    fontSize: 13, color: SahelColors.text, height: 1.5)),
          ],
          if (reply.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: SahelColors.primarySurface,
                borderRadius: SahelRadii.smRadius,
              ),
              child: Text('ردك: $reply',
                  style: const TextStyle(fontSize: 12)),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              if (date.isNotEmpty)
                Text(date,
                    style: const TextStyle(
                        fontSize: 11, color: SahelColors.textSoft)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _reply(context, ref),
                icon: Icon(reply.isEmpty
                    ? Icons.reply
                    : Icons.edit_outlined,
                    size: 16),
                label: Text(reply.isEmpty ? 'الرد على المراجعة' : 'تعديل الرد'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _reply(BuildContext context, WidgetRef ref) async {
    final reply = str(review['reply'] ?? review['provider_reply']);
    final controller = TextEditingController(text: reply);
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('الرد على المراجعة'),
        content: TextField(
          controller: controller,
          maxLength: 500,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'شكراً لتقييمكم — نحسّن خدماتنا دائماً',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('إرسال الرد')),
        ],
      ),
    );
    if (text == null || text.isEmpty || !context.mounted) return;
    try {
      await ref.read(providerRepositoryProvider).replyReview(
            str(review['id']),
            text,
          );
      ref.invalidate(providerReviewsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
              const SnackBar(content: Text('تم إرسال الرد ✓')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(const SnackBar(
              content: Text('تعذر إرسال الرد'),
              backgroundColor: SahelColors.danger));
      }
    }
  }
}
