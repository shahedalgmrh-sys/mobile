import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/empty_state.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';

class ProviderInboxScreen extends ConsumerWidget {
  const ProviderInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convs = ref.watch(providerConversationsProvider);

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
            ],
          ),
          error: (e, _) => Center(
            child: TextButton.icon(
              onPressed: () => ref.invalidate(providerConversationsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const Center(
                child: EmptyState(
                  title: 'لا توجد رسائل بعد',
                  subtitle: 'ستظهر محادثات العملاء هنا',
                  icon: Icons.chat_outlined,
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(providerConversationsProvider),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final c = items[i];
                  // ConversationResource exposes `participants[]`; pick the
                  // first non-provider participant as the customer.
                  final participants = dataList(c['participants']);
                  Map<String, dynamic> other = const {};
                  for (final p in participants) {
                    final m = asMap(p);
                    final role = str(m['role']);
                    if (role.isNotEmpty && role != 'provider') {
                      other = m;
                      break;
                    }
                  }
                  if (other.isEmpty && participants.isNotEmpty) {
                    other = asMap(participants.first);
                  }
                  if (other.isEmpty) {
                    other = asMap(
                      c['customer'] ??
                          c['other_party'] ??
                          c['participant'] ??
                          c['user'],
                    );
                  }
                  final name = str(other['name'] ?? c['title'], 'عميل');
                  final lastMsg = asMap(
                    c['last_message'] ?? c['latest_message'],
                  );
                  final preview = str(
                    lastMsg['body'] ?? c['last_message_preview'],
                  );
                  // The provider resource does not include an unread counter.
                  final unread = toInt(c['unread_count']);
                  final threadId = str(c['id'] ?? c['conversation_id']);

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(name.isNotEmpty ? name[0] : '؟'),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      preview.isEmpty ? '—' : preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: unread > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: SahelColors.primary600,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$unread',
                              style: const TextStyle(
                                color: SahelColors.onPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          )
                        : null,
                    onTap: threadId.isEmpty
                        ? null
                        : () => context.push('/p/inbox/$threadId'),
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
