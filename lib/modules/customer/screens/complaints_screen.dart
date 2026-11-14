import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

import 'complaints/complaint_helpers.dart';

/// Customer complaint history.
///
/// API surface for customers: `GET /customer/complaints` (last 15, messages
/// included) and `POST /customer/complaints`. Detail/reply/close are web-only
/// session routes, so the app shows the thread read-only.
class CustomerComplaintsScreen extends ConsumerWidget {
  const CustomerComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaints = ref.watch(customerComplaintsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('شكاوى'),
        actions: [
          IconButton(
            tooltip: 'شكوى جديدة',
            onPressed: () => context.push('/complaints/new'),
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
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final c in items) ...[
                  _ComplaintCard(c: c),
                  const SizedBox(height: 10),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'يعرض API آخر 15 شكوى — تُدار الردود والإغلاق من فريق الدعم.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: SahelColors.textSoft),
                  ),
                ),
              ],
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

  @override
  Widget build(BuildContext context) {
    final id = str(c['id']);
    final subject = str(c['subject'], 'شكوى');
    final body = str(c['description']);
    final status = str(c['status'], 'open');
    final priority = str(c['priority'], 'medium');
    final number = str(c['complaint_number']);
    final date = complaintDate(c['created_at']);
    final latest = complaintLatestMessage(c);
    final reply = latest == null ? '' : str(latest['message']);
    final statusColor = complaintStatusColor(status);

    return Material(
      color: SahelColors.surface,
      borderRadius: SahelRadii.mdRadius,
      child: InkWell(
        borderRadius: SahelRadii.mdRadius,
        onTap: id.isEmpty ? null : () => context.push('/complaints/$id'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: SahelRadii.mdRadius,
            border: Border.all(color: SahelColors.border),
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
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: SahelRadii.pillRadius,
                    ),
                    child: Text(complaintStatusLabel(status),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: statusColor)),
                  ),
                ],
              ),
              if (body.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: SahelColors.textMuted, height: 1.5)),
              ],
              if (reply.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: SahelColors.infoSoft,
                    borderRadius: SahelRadii.smRadius,
                  ),
                  child: Text('رد الدعم: $reply',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: SahelColors.text)),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: complaintPriorityColor(priority)
                          .withValues(alpha: 0.10),
                      borderRadius: SahelRadii.pillRadius,
                    ),
                    child: Text(
                      'أولوية ${complaintPriorityLabel(priority)}',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: complaintPriorityColor(priority)),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    [if (number.isNotEmpty) number, if (date.isNotEmpty) date]
                        .join(' · '),
                    style: const TextStyle(
                        fontSize: 10, color: SahelColors.textSoft),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
