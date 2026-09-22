import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/models/booking_status.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';
import '../../../shared/theme/sahel_colors.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String threadId;

  const ChatScreen({
    super.key,
    required this.threadId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  int get _id => int.tryParse(widget.threadId) ?? 0;

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

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      if (_isProvider) {
        await ref.read(providerRepositoryProvider).sendMessage(_id, text);
      } else {
        await ref.read(customerRepositoryProvider).sendMessage(_id, text);
      }
      _controller.clear();
      _invalidate();
      await Future.delayed(const Duration(milliseconds: 200));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر إرسال الرسالة')),
        );
      }
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
            final other = asMap(
                c['other_party'] ?? c['provider'] ?? c['customer']);
            final otherUser = asMap(other['user']);
            final name = str(other['business_name'] ?? otherUser['name'],
                'محادثة');
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                  child: Text(name.isNotEmpty ? name[0] : '؟')),
              title: Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
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
              error: (e, _) => Center(
                child: TextButton.icon(
                  onPressed: _invalidate,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ),
              data: (c) {
                final messages =
                    asMapList(c['messages'] ?? c['data']);
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('ابدأ المحادثة…',
                        style: TextStyle(color: SahelColors.muted)),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final m = messages[i];
                    final senderId =
                        str(m['sender_id'] ?? asMap(m['sender'])['id']);
                    final isMe = senderId == myId ||
                        toBool(m['is_mine']) ||
                        str(m['sender_type']) ==
                            (_isProvider ? 'provider' : 'customer');
                    return _bubble(
                      str(m['body'] ?? m['message']),
                      isMe,
                      _fmtTime(str(m['created_at'])),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border(top: BorderSide(color: SahelColors.slate200)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالتك...',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        filled: true,
                        fillColor: SahelColors.slate50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
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
                                strokeWidth: 2, color: Colors.white),
                          )
                        : IconButton(
                            onPressed: _send,
                            icon: const Icon(Icons.send,
                                color: Colors.white, size: 20),
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
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _bubble(String text, bool me, String time) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: 8, left: me ? 60 : 0, right: me ? 0 : 60),
      child: Column(
        crossAxisAlignment:
            me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: me ? SahelColors.primary600 : SahelColors.slate100,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(me ? 14 : 4),
                bottomRight: Radius.circular(me ? 4 : 14),
              ),
            ),
            child: Text(text,
                style: TextStyle(
                    color: me ? Colors.white : SahelColors.text,
                    height: 1.4)),
          ),
          const SizedBox(height: 4),
          Text(time,
              style: const TextStyle(
                  fontSize: 10, color: SahelColors.muted)),
        ],
      ),
    );
  }
}
