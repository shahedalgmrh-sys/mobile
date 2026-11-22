import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/core/constants/enums.dart';
import 'package:saber_flutter/core/errors/failures.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart'
    show ApiException;
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String threadId;

  const ChatScreen({super.key, required this.threadId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;
  bool _didInitialScroll = false;

  String get _id => widget.threadId;

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.threadId != widget.threadId) {
      _didInitialScroll = false;
      _sending = false;
    }
  }

  bool get _isProvider =>
      ref.read(authNotifierProvider).role == UserRole.provider;

  AsyncValue<Map<String, dynamic>> get _conv => _isProvider
      ? ref.watch(providerConversationProvider(_id))
      : ref.watch(customerConversationProvider(_id));

  void _invalidate() {
    if (_isProvider) {
      ref.invalidate(providerConversationProvider(_id));
      ref.invalidate(providerConversationsProvider);
    } else {
      ref.invalidate(customerConversationProvider(_id));
      ref.invalidate(customerConversationsProvider);
    }
  }

  void _retryLoad() {
    _didInitialScroll = false;
    _invalidate();
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients) return true;
    final position = _scrollController.position;
    if (!position.hasContentDimensions) return true;
    return position.maxScrollExtent - position.pixels <= 120;
  }

  void _animateToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final position = _scrollController.position;
      if (!position.hasContentDimensions) return;
      _scrollController.animateTo(
        position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  /// Positions the thread on the newest message once the first frame (and the
  /// lazily built items) have laid out. Extra passes are needed because
  /// `ListView.builder` refines `maxScrollExtent` as more items are built.
  void _scheduleInitialScroll() {
    if (_didInitialScroll) return;
    _didInitialScroll = true;
    _jumpToBottomPasses(3);
  }

  void _jumpToBottomPasses(int remaining) {
    if (remaining <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients &&
          _scrollController.position.hasContentDimensions) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
      _jumpToBottomPasses(remaining - 1);
    });
  }

  Future<void> _reloadConversation() async {
    if (_isProvider) {
      ref.invalidate(providerConversationProvider(_id));
      ref.invalidate(providerConversationsProvider);
      try {
        await ref.read(providerConversationProvider(_id).future);
      } catch (_) {
        // The message was accepted by the API; a failed refresh only means
        // the canonical thread cannot be reloaded right now.
      }
    } else {
      ref.invalidate(customerConversationProvider(_id));
      ref.invalidate(customerConversationsProvider);
      try {
        await ref.read(customerConversationProvider(_id).future);
      } catch (_) {}
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    final wasNearBottom = _isNearBottom();
    setState(() => _sending = true);
    final session = ref.read(sessionScopeProvider);
    try {
      try {
        if (_isProvider) {
          await ref.read(providerRepositoryProvider).sendMessage(_id, text);
        } else {
          await ref.read(customerRepositoryProvider).sendMessage(_id, text);
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  _errorMessage(
                    error,
                    fallback: 'تعذر إرسال الرسالة. حاول مجدداً.',
                  ),
                ),
              ),
            );
        }
        // Keep the typed text so the user can retry without retyping.
        return;
      }
      // The message was accepted under [session]. If the account changed
      // meanwhile, refresh nothing and show nothing in the new session.
      if (!ref.read(sessionScopeProvider).sameSession(session)) return;
      if (!mounted) return;
      _controller.clear();
      await _reloadConversation();
      if (!mounted) return;
      if (wasNearBottom) _animateToBottom();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conv = _conv;
    final myId = str(ref.watch(authNotifierProvider).userId);

    return Scaffold(
      appBar: AppBar(
        title: conv.maybeWhen(
          data: (c) {
            final participants = dataList(c['participants']);
            Map<String, dynamic> other = const {};
            for (final p in participants) {
              final m = asMap(p);
              if (str(m['id']) != myId && str(m['id']).isNotEmpty) {
                other = m;
                break;
              }
            }
            if (other.isEmpty) {
              other = asMap(
                c['other_party'] ?? c['provider'] ?? c['customer'] ?? c['user'],
              );
            }
            final otherUser = asMap(other['user']);
            final name = str(
              other['business_name'] ?? other['name'] ?? otherUser['name'],
              'محادثة',
            );
            final avatarUrl = str(
              other['avatar'] ?? otherUser['avatar'] ?? other['business_logo'],
            );
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _SenderAvatar(url: avatarUrl, name: name, radius: 18),
              title: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            );
          },
          orElse: () => const Text('محادثة'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: conv.when(
              loading: () => ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  ShimmerCard(height: 56),
                  SizedBox(height: 8),
                  ShimmerCard(height: 56),
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
                        onPressed: _retryLoad,
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (c) {
                final messages = dataList(
                  c['messages'] ??
                      c['chat_messages'] ??
                      c['items'] ??
                      c['data'],
                );
                if (messages.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        _isProvider
                            ? 'لا يعرض الخادم سجل الرسائل السابقة لحساب المزوّد حالياً — يمكنك إرسال رسالة جديدة.'
                            : 'ابدأ المحادثة…',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: SahelColors.muted),
                      ),
                    ),
                  );
                }
                _scheduleInitialScroll();
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final m = messages[i];
                    final sender = asMap(m['sender']);
                    final senderId = str(sender['id'] ?? m['sender_id']);
                    final isMe = senderId.isNotEmpty
                        ? senderId == myId
                        : toBool(m['is_mine']);
                    return _bubble(
                      text: str(m['body'] ?? m['message']),
                      me: isMe,
                      time: _fmtTime(str(m['created_at'])),
                      senderName: str(sender['name']),
                      senderAvatar: str(sender['avatar']),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: SahelColors.onPrimary,
              border: Border(top: BorderSide(color: SahelColors.slate200)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالتك...',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: SahelColors.slate50,
                        border: OutlineInputBorder(
                          borderRadius: SahelRadii.pillRadius,
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: SahelColors.primary600,
                    child: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: SahelColors.onPrimary,
                            ),
                          )
                        : IconButton(
                            onPressed: _send,
                            icon: const Icon(
                              Icons.send,
                              color: SahelColors.onPrimary,
                              size: 20,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtTime(String iso) {
    final dt = toDate(iso)?.toLocal();
    if (dt == null) return '';
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _bubble({
    required String text,
    required bool me,
    required String time,
    required String senderName,
    required String senderAvatar,
  }) {
    final content = Column(
      crossAxisAlignment: me
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Incoming messages carry the sender identity shipped by the API;
        // outgoing bubbles stay exactly as before.
        if (!me && senderName.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, bottom: 3),
            child: Text(
              senderName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: SahelColors.textMuted,
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: me ? SahelColors.primary600 : SahelColors.slate100,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(me ? 14 : 4),
              bottomRight: Radius.circular(me ? 4 : 14),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: me ? SahelColors.onPrimary : SahelColors.text,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(fontSize: 10, color: SahelColors.muted),
        ),
      ],
    );

    if (me) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 60),
        child: content,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _SenderAvatar(url: senderAvatar, name: senderName, radius: 14),
          const SizedBox(width: 8),
          Flexible(child: content),
        ],
      ),
    );
  }
}

/// Circle avatar for the other participant / message sender. Falls back to the
/// name's initial, then to a neutral person icon when the API ships neither
/// an image nor a name.
class _SenderAvatar extends StatelessWidget {
  const _SenderAvatar({this.url = '', this.name = '', this.radius = 16});

  final String url;
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final fallback = trimmed.isNotEmpty
        ? Text(trimmed[0], style: TextStyle(fontSize: radius * 0.9))
        : Icon(Icons.person_outline, size: radius * 1.2);
    final imageUrl = url.trim();
    return CircleAvatar(
      radius: radius,
      foregroundImage: imageUrl.isEmpty ? null : NetworkImage(imageUrl),
      onForegroundImageError: imageUrl.isEmpty ? null : (_, __) {},
      child: fallback,
    );
  }
}

/// Surfaces the message mapped by [ApiClient] (`ServerFailure.message`) so
/// load/send failures are actionable instead of an unlabeled retry.
String _errorMessage(Object error, {String fallback = 'تعذر تحميل المحادثة.'}) {
  final failure = error is ApiException
      ? error.failure
      : (error is Failure ? error : null);
  if (failure is ServerFailure) {
    return failure.message.trim().isNotEmpty ? failure.message : fallback;
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
  return fallback;
}
