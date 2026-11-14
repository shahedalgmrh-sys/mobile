import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';

class ProviderNotificationsScreen extends ConsumerWidget {
  const ProviderNotificationsScreen({super.key});

  static (IconData, Color) _icon(String type) {
    final t = type.toLowerCase();
    if (t.contains('booking')) return (Icons.add_task, SahelColors.green600);
    if (t.contains('review') || t.contains('rating')) {
      return (Icons.reviews_outlined, SahelColors.amber500);
    }
    if (t.contains('payment') || t.contains('payout') || t.contains('wallet')) {
      return (Icons.payments_outlined, SahelColors.primary600);
    }
    return (Icons.notifications_outlined, SahelColors.primary600);
  }

  static String _ago(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    return 'منذ ${diff.inDays} أيام';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(providerNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          IconButton(
            tooltip: 'تعليم الكل كمقروء',
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              try {
                await ref
                    .read(providerRepositoryProvider)
                    .markAllNotificationsRead();
                ref.invalidate(providerNotificationsProvider);
              } catch (_) {}
            },
          ),
        ],
      ),
      body: SafeArea(
        child: notifs.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ShimmerCard(height: 80),
              SizedBox(height: 10),
              ShimmerCard(height: 80),
            ],
          ),
          error: (e, _) => Center(
            child: TextButton.icon(
              onPressed: () => ref.invalidate(providerNotificationsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد إشعارات',
                  style: TextStyle(
                    color: SahelColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(providerNotificationsProvider),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  final n = items[i];
                  final data = asMap(n['data']);
                  final title = str(data['title'] ?? n['title'], 'إشعار');
                  final body = str(
                    data['body'] ?? data['message'] ?? n['body'],
                  );
                  final (icon, color) = _icon(str(n['type']));
                  final isUnread = n['read_at'] == null;
                  return GestureDetector(
                    onTap: isUnread
                        ? () async {
                            try {
                              await ref
                                  .read(providerRepositoryProvider)
                                  .markNotificationRead(str(n['id']));
                              ref.invalidate(providerNotificationsProvider);
                            } catch (_) {}
                          }
                        : null,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isUnread
                            ? SahelColors.primary50.withValues(alpha: 0.5)
                            : SahelColors.onPrimary,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: SahelColors.slate200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: color.withValues(alpha: 0.12),
                            child: Icon(icon, color: color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _ago(str(n['created_at'])),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: SahelColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                                if (body.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    body,
                                    style: const TextStyle(
                                      color: SahelColors.muted,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
