import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/core/errors/failures.dart';
import 'package:saber_flutter/core/utils/format.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart'
    show ApiException;
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/empty_state.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

class MessagesListScreen extends ConsumerWidget {
  const MessagesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convs = ref.watch(customerConversationsProvider);
    final myId = str(ref.watch(authNotifierProvider).userId);

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
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 40,
                    color: SahelColors.textMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage(error),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: SahelColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () =>
                        ref.invalidate(customerConversationsProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
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
                  final other = _otherParty(c, myId);
                  final otherUser = asMap(other['user']);
                  // ConversationResource exposes the other side through
                  // `participants[]`; `subject` is the last-resort label.
                  final name = str(
                    other['business_name'] ??
                        other['name'] ??
                        otherUser['name'] ??
                        c['subject'],
                    'محادثة',
                  );
                  final avatarUrl = str(
                    other['avatar'] ??
                        otherUser['avatar'] ??
                        other['business_logo'],
                  );
                  final lastMsg = asMap(
                    c['latest_message'] ?? c['last_message'],
                  );
                  final preview = str(
                    lastMsg['body'] ?? c['last_message_preview'],
                  );
                  final at = formatDate(
                    c['last_message_at'] ??
                        lastMsg['created_at'] ??
                        c['updated_at'],
                  );
                  final unread = toInt(c['unread_count']);
                  final threadId = str(c['id'] ?? c['conversation_id']);

                  return ListTile(
                    leading: _Avatar(url: avatarUrl, name: name),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
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
                            at,
                            style: const TextStyle(
                              fontSize: 11,
                              color: SahelColors.textMuted,
                            ),
                          ),
                        if (unread > 0)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: SahelColors.primary,
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

/// Picks the conversation participant that is not the signed-in user.
/// Falls back to the first participant (or the legacy single-party fields)
/// so a malformed/partial payload never hides the row.
Map<String, dynamic> _otherParty(
  Map<String, dynamic> conversation,
  String myId,
) {
  final participants = dataList(conversation['participants']);
  for (final raw in participants) {
    final participant = asMap(raw);
    if (participant.isEmpty) continue;
    if (myId.isEmpty || str(participant['id']) != myId) {
      return participant;
    }
  }
  if (participants.isNotEmpty) return asMap(participants.first);
  return asMap(
    conversation['other_party'] ??
        conversation['provider'] ??
        conversation['participant'] ??
        conversation['user'],
  );
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.name});

  final String url;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name.substring(0, 1) : '؟';
    if (url.isEmpty) return CircleAvatar(child: Text(initial));

    return CircleAvatar(
      // The letter stays underneath and is revealed if the photo fails.
      foregroundImage: NetworkImage(url),
      onForegroundImageError: (_, __) {},
      child: Text(initial),
    );
  }
}

/// Surfaces the message mapped by [ApiClient] (`ServerFailure.message`) so
/// 403/404/network failures are actionable instead of an unlabeled retry.
String _errorMessage(Object error) {
  if (error is ApiException) {
    final failure = error.failure;
    if (failure is ServerFailure) {
      return failure.message.trim().isNotEmpty
          ? failure.message
          : 'تعذر تحميل المحادثات.';
    }
    if (failure is NetworkFailure) {
      return 'تعذر الاتصال بالخادم. تحقق من الشبكة.';
    }
    if (failure is UnauthorizedFailure) {
      return 'انتهت الجلسة. سجّل الدخول مجدداً.';
    }
    if (failure is ValidationFailure) {
      final messages = failure.errors.values
          .expand((list) => list)
          .where((message) => message.trim().isNotEmpty);
      if (messages.isNotEmpty) return messages.join('\n');
    }
  }
  return 'تعذر تحميل المحادثات. حاول مجدداً.';
}
