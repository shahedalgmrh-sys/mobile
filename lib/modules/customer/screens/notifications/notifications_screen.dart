import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  static const _tabs = ['الكل', 'الحجوزات', 'المدفوعات', 'المحادثات', 'أخرى'];
  static const _tabKeys = [null, 'booking', 'payment', 'chat', '_other'];

  static (IconData, Color, Color) _style(String type) {
    if (type.contains('booking')) {
      return (Icons.calendar_month, SahelColors.primary600, SahelColors.primary50);
    }
    if (type.contains('payment') ||
        type.contains('wallet') ||
        type.contains('payout')) {
      return (Icons.account_balance_wallet, SahelColors.amber, SahelColors.amberSoft);
    }
    if (type.contains('message') || type.contains('chat') || type.contains('conversation')) {
      return (Icons.chat_bubble_outline, SahelColors.info, SahelColors.infoSoft);
    }
    return (Icons.notifications_outlined, SahelColors.violet, SahelColors.violetSoft);
  }

  static String _key(Map<String, dynamic> n) {
    final t = str(n['type']).toLowerCase();
    if (t.contains('booking')) return 'booking';
    if (t.contains('payment') || t.contains('wallet')) return 'payment';
    if (t.contains('message') || t.contains('chat') || t.contains('conversation')) {
      return 'chat';
    }
    return '_other';
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
    final notifs = ref.watch(customerNotificationsProvider);

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإشعارات',
              style: TextStyle(fontWeight: FontWeight.w800)),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () async {
                final items =
                    ref.read(customerNotificationsProvider).valueOrNull ??
                        const <Map<String, dynamic>>[];
                final repo = ref.read(customerRepositoryProvider);
                for (final n in items) {
                  if (n['read_at'] == null) {
                    try {
                      await repo.markNotificationRead(str(n['id']));
                    } catch (_) {}
                  }
                }
                ref.invalidate(customerNotificationsProvider);
                ref.invalidate(unreadNotificationsProvider);
              },
              icon: const Icon(Icons.mark_email_read_outlined,
                  color: SahelColors.primary700),
              tooltip: 'تعليم الكل كمقروء',
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            labelColor: SahelColors.primary700,
            unselectedLabelColor: SahelColors.textMuted,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            indicatorColor: SahelColors.primary700,
            indicatorWeight: 3,
            tabs: [for (final t in _tabs) Tab(text: t)],
          ),
        ),
        body: notifs.when(
          loading: () => ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: 5,
            itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: ShimmerCard(height: 72),
            ),
          ),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined,
                    size: 56, color: SahelColors.textMuted),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () =>
                      ref.invalidate(customerNotificationsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
          data: (items) => TabBarView(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                _NotificationList(
                  items: _tabKeys[i] == null
                      ? items
                      : items
                          .where((n) => _key(n) == _tabKeys[i])
                          .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationList extends ConsumerWidget {
  final List<Map<String, dynamic>> items;
  const _NotificationList({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 56, color: SahelColors.textMuted),
            SizedBox(height: 12),
            Text(
              'لا توجد إشعارات',
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: SahelColors.textMuted),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final n = items[i];
        final data = asMap(n['data']);
        final title = str(data['title'] ?? n['title'], 'إشعار');
        final body = str(data['body'] ?? data['message'] ?? n['body']);
        final isUnread = n['read_at'] == null;
        final meta = NotificationsScreen._style(str(n['type']));
        final when = NotificationsScreen._ago(
            str(n['created_at'] ?? n['createdAt']));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Material(
            color: isUnread
                ? SahelColors.primary50.withOpacity(0.4)
                : SahelColors.surface,
            borderRadius: SahelRadii.mdRadius,
            child: InkWell(
              onTap: () async {
                if (isUnread) {
                  try {
                    await ref
                        .read(customerRepositoryProvider)
                        .markNotificationRead(str(n['id']));
                    ref.invalidate(customerNotificationsProvider);
                    ref.invalidate(unreadNotificationsProvider);
                  } catch (_) {}
                }
                final bookingId = toInt(data['booking_id']);
                if (bookingId > 0 && ctx.mounted) {
                  ctx.push('/bookings/$bookingId');
                }
              },
              borderRadius: SahelRadii.mdRadius,
              child: Container(
              decoration: BoxDecoration(
                borderRadius: SahelRadii.mdRadius,
                border: Border.all(
                    color: isUnread
                        ? SahelColors.primary200
                        : SahelColors.border),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: meta.$3,
                    child: Icon(meta.$1, color: meta.$2, size: 22),
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
                                style: TextStyle(
                                  fontWeight: isUnread
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  fontSize: 13,
                                  color: SahelColors.text,
                                ),
                              ),
                            ),
                            if (isUnread) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: SahelColors.primary600,
                                  borderRadius: SahelRadii.pillRadius,
                                ),
                                child: const Text(
                                  'جديد',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (body.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: SahelColors.textMuted),
                          ),
                        ],
                        if (when.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            when,
                            style: const TextStyle(
                                fontSize: 11,
                                color: SahelColors.textMuted,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
        );
      },
    );
  }
}
