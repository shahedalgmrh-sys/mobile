import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';

class SubmitComplaintScreen extends ConsumerStatefulWidget {
  final String id;

  const SubmitComplaintScreen({
    super.key,
    this.id = '',
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

  static const _priorities = [
    ('low', 'منخفضة'),
    ('medium', 'متوسطة'),
    ('high', 'عالية'),
    ('urgent', 'عاجلة'),
  ];

  String? _subject;
  String _priority = 'medium';
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
    final session = ref.read(sessionScopeProvider);
    try {
      final complaint = await ref.read(customerRepositoryProvider).storeComplaint(
            bookingId: widget.id.isEmpty ? null : widget.id,
            subject: _subject!,
            description: _description.text.trim(),
            priority: _priority,
          );
      if (!ref.read(sessionScopeProvider).sameSession(session)) return;
      ref.invalidate(customerComplaintsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم إرسال البلاغ — سيتواصل معك الدعم')));
      final newId = complaint['id']?.toString() ?? '';
      if (newId.isNotEmpty) {
        context.pushReplacement('/complaints/$newId');
      } else {
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
        child: ListView(
          padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 20),
            const Text('درجة الأولوية',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (id, label) in _priorities)
                  _priorityChip(id, label),
              ],
            ),
            if (widget.id.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.link, size: 16, color: SahelColors.textMuted),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text('ستُربط الشكوى بالحجز المفتوح.',
                        style: TextStyle(
                            fontSize: 12, color: SahelColors.textMuted)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            TextField(
              controller: _description,
              maxLines: 6,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'صف المشكلة بالتفصيل...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
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
    );
  }

  Widget _chip(String t) {
    final selected = _subject == t;
    return InkWell(
      onTap: () => setState(() => _subject = t),
      borderRadius: SahelRadii.pillRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? SahelColors.primary50 : SahelColors.slate100,
          borderRadius: SahelRadii.pillRadius,
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

  Widget _priorityChip(String id, String label) {
    final selected = _priority == id;
    final color = id == 'urgent'
        ? SahelColors.danger
        : id == 'high'
            ? SahelColors.amber700
            : SahelColors.primary600;
    return InkWell(
      onTap: () => setState(() => _priority = id),
      borderRadius: SahelRadii.pillRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : SahelColors.slate100,
          borderRadius: SahelRadii.pillRadius,
          border: Border.all(
              color: selected ? color : SahelColors.slate200),
        ),
        child: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: selected ? color : null)),
      ),
    );
  }
}
