import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import '../../../shared/theme/sahel_colors.dart';

class SubmitComplaintScreen extends ConsumerStatefulWidget {
  final String id;

  const SubmitComplaintScreen({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<SubmitComplaintScreen> createState() =>
      _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState
    extends ConsumerState<SubmitComplaintScreen> {
  static const _subjects = [
    'تأخر المزود',
    'جودة منخفضة',
    'سلوك غير لائق',
    'اتصال منقطع',
    'تكلفة إضافية',
    'أخرى',
  ];

  String? _subject;
  final _description = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_subject == null || _description.text.trim().isEmpty || _submitting) {
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(customerRepositoryProvider).storeComplaint(
            bookingId: widget.id,
            subject: _subject!,
            description: _description.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تم إرسال البلاغ — سيتواصل معك الدعم')));
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر إرسال البلاغ — حاول لاحقاً')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        _subject != null && _description.text.trim().isNotEmpty && !_submitting;
    return Scaffold(
      appBar: AppBar(title: const Text('إبلاغ عن مشكلة')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ما نوع المشكلة؟',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in _subjects) _chip(s),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _description,
                maxLines: 6,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'صف المشكلة بالتفصيل...',
                  alignLabelWithHint: true,
                ),
              ),
              const Spacer(),
              _submitting
                  ? const Center(child: CircularProgressIndicator())
                  : SahelButton(
                      label: 'إرسال البلاغ',
                      variant: SahelButtonVariant.danger,
                      onPressed: canSubmit ? _submit : null,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String t) {
    final selected = _subject == t;
    return InkWell(
      onTap: () => setState(() => _subject = t),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? SahelColors.primary50 : SahelColors.slate100,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: selected ? SahelColors.primary600 : SahelColors.slate200),
        ),
        child: Text(t,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: selected ? SahelColors.primary700 : null)),
      ),
    );
  }
}
