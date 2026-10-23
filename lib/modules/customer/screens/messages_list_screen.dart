import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/empty_state.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

class MessagesListScreen extends ConsumerWidget {
  const MessagesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convs = ref.watch(customerConversationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الرسائل')),
      body: SafeArea(
        child: convs.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ShimmerCard(height: 64),
              SizedBox(height: 8),
              ShimmerCard(height: 64),
              SizedBox(height: 8),
              ShimmerCard(height: 64),
            ],
          ),
          error: (e, _) => Center(
            child: TextButton.icon(
              onPressed: () =>
                  ref.invalidate(customerConversationsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const Center(
                child: EmptyState(
                  title: 'لا توجد رسائل بعد',
                  subtitle: 'تبدأ المحادثة مع مزود الخدمة بعد الحجز',
                  icon: Icons.chat_outlined,
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(customerConversationsProvider),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final c = items[i];
                  final other = asMap(c['other_party'] ??
                      c['provider'] ??
                      c['participant'] ??
                      c['user']);
                  final otherUser = asMap(other['user']);
                  final name = str(other['business_name'] ??
                      otherUser['name'] ??
                      c['title'],
                      'محادثة');
                  final lastMsg = asMap(c['last_message'] ?? c['latest_message']);
                  final preview = str(
                      lastMsg['body'] ?? c['last_message_preview']);
                  final at = str(lastMsg['created_at'] ??
                      c['last_message_at'] ??
                      c['updated_at']);
                  final unread = toInt(c['unread_count']);
                  final threadId = str(c['id'] ?? c['conversation_id']);

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(name.isNotEmpty ? name[0] : '؟'),
                    ),
                    title: Text(name,
                        style:
                            const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      preview.isEmpty ? '—' : preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (at.isNotEmpty)
                          Text(
                            at.length > 10 ? at.substring(0, 10) : at,
                            style: const TextStyle(
                                fontSize: 11, color: SahelColors.textMuted),
                          ),
                        if (unread > 0)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: SahelColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$unread',
                              style: const TextStyle(
                                  color: SahelColors.onPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                      ],
                    ),
                    onTap: threadId.isEmpty
                        ? null
                        : () => context.push('/inbox/$threadId'),
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
