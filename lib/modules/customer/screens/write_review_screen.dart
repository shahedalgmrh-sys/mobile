import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  final String id;

  const WriteReviewScreen({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  double _overall = 0;
  final _comment = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_overall < 1 || _submitting) return;
    setState(() => _submitting = true);
    final session = ref.read(sessionScopeProvider);
    try {
      await ref.read(customerRepositoryProvider).storeReview(
            bookingId: widget.id,
            rating: _overall.round(),
            comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
          );
      if (!ref.read(sessionScopeProvider).sameSession(session)) return;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('شكراً لك — تم نشر تقييمك')));
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر إرسال التقييم — حاول لاحقاً')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('كتابة تقييم')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('كيف كانت تجربتك؟',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => _overall = (i + 1).toDouble()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        i < _overall ? Icons.star : Icons.star_outline,
                        size: 40,
                        color: SahelColors.amber500,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _comment,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'أخبرنا أكثر عن تجربتك مع مزود الخدمة...',
                ),
              ),
              const Spacer(),
              _submitting
                  ? const Center(child: CircularProgressIndicator())
                  : SahelButton(
                      label: 'نشر التقييم',
                      variant: SahelButtonVariant.gradient,
                      onPressed: _overall >= 1 ? _submit : null,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
