import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

/// Customer complaint history — mirrors the website `/complaints` list.
/// The server API surface exposes list + store only (thread/reply/close are
/// web-only routes); this screen therefore renders status + admin response.
class CustomerComplaintsScreen extends ConsumerWidget {
  const CustomerComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaints = ref.watch(customerComplaintsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('شكاواي'),
        actions: [
          IconButton(
            tooltip: 'شكوى جديدة',
            onPressed: () => context.push('/complaint'),
            icon: const Icon(Icons.add_comment_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(customerComplaintsProvider),
        child: complaints.when(
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
                onPressed: () => ref.invalidate(customerComplaintsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ),
          ]),
          data: (items) {
            if (items.isEmpty) {
              return ListView(children: [
                const SizedBox(height: 110),
                Column(
                  children: [
                    const Icon(Icons.support_agent_outlined,
                        size: 46, color: SahelColors.textSoft),
                    const SizedBox(height: 12),
                    const Text('لا توجد شكاوى بعد',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: SahelColors.muted)),
                    const SizedBox(height: 14),
                    SahelButton.outline(
                      label: 'إرسال شكوى جديدة',
                      onPressed: () => context.push('/complaints/new'),
                    ),
                  ],
                ),
              ]);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _ComplaintCard(c: items[i]),
            );
          },
        ),
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final Map<String, dynamic> c;
  const _ComplaintCard({required this.c});

  Color _statusColor(String s) {
    s = s.toLowerCase();
    if (s.contains('resolved') || s.contains('closed')) {
      return SahelColors.success;
    }
    if (s.contains('open') || s.contains('new')) return SahelColors.info;
    return SahelColors.amber500;
  }

  String _statusLabel(String s) {
    s = s.toLowerCase();
    if (s.contains('resolved') || s.contains('closed')) return 'تم الحل';
    if (s.contains('open') || s.contains('new')) return 'مفتوحة';
    if (s.contains('progress')) return 'قيد المعالجة';
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final subject = str(c['subject'] ?? c['title'], 'شكوى');
    final body = str(c['description'] ?? c['message'] ?? c['body']);
    final status = str(c['status'], 'pending');
    final response = str(c['admin_response'] ?? c['response']);
    final date = str(
        c['date_ar'] ?? c['formatted_created_at'] ?? c['created_at']);
    final name = str(c['customer_name']);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: SahelRadii.mdRadius,
        border: Border.all(color: SahelColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 14)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.12),
                  borderRadius: SahelRadii.pillRadius,
                ),
                child: Text(_statusLabel(status),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _statusColor(status))),
              ),
            ],
          ),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12, color: SahelColors.textMuted, height: 1.5)),
          ],
          if (response.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: SahelColors.infoSoft,
                borderRadius: SahelRadii.smRadius,
              ),
              child: Text('رد الدعم: $response',
                  style: const TextStyle(
                      fontSize: 12, color: SahelColors.text)),
            ),
          ],
          if (name.isNotEmpty || date.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              [if (date.isNotEmpty) date].join(' · '),
              style: const TextStyle(fontSize: 11, color: SahelColors.textSoft),
            ),
          ],
        ],
      ),
    );
  }
}
