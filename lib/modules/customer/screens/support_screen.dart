import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import '../../../shared/widgets/sahel_button.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  final _subject = TextEditingController();
  final _message = TextEditingController();
  final _email = TextEditingController();
  bool _sending = false;
  bool _showFaqs = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user ?? {};
    _email.text = str(user['email']);
  }

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _email.text.trim();
    final emailValid =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (_subject.text.trim().isEmpty ||
        _message.text.trim().isEmpty ||
        _sending) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('أدخل الموضوع ونص الرسالة')));
      return;
    }
    if (!emailValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('أدخل بريدًا إلكترونيًا صالحًا للرد عليك')));
      return;
    }
    setState(() => _sending = true);
    try {
      final user = ref.read(authNotifierProvider).user ?? {};
      await ref.read(catalogRepositoryProvider).sendContactMessage(
            name: str(user['name'], 'مستخدم التطبيق'),
            email: email,
            phone: str(user['phone']),
            subject: _subject.text.trim(),
            message: _message.text.trim(),
          );
      if (mounted) {
        _subject.clear();
        _message.clear();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تم إرسال رسالتك — سنرد عليك قريباً')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تعذر إرسال الرسالة — حاول لاحقاً')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final faqs = ref.watch(faqsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الدعم والمساعدة')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: SahelColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.support_agent,
                      size: 44, color: SahelColors.onPrimary),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('فريق الدعم متاح 24/7',
                            style: TextStyle(
                                color: SahelColors.onPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 16)),
                        SizedBox(height: 4),
                        Text('متوسط وقت الرد: أقل من 5 دقائق',
                            style: TextStyle(
                                color: SahelColors.onPrimary70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _tile(Icons.help_outline, 'الأسئلة الشائعة',
                'إجابات لأكثر الاستفسارات شيوعاً',
                onTap: () => setState(() => _showFaqs = !_showFaqs)),
            if (_showFaqs)
              faqs.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('تعذر تحميل الأسئلة',
                      style: TextStyle(color: SahelColors.muted)),
                ),
                data: (items) => items.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('لا توجد أسئلة شائعة حالياً',
                            style:
                                TextStyle(color: SahelColors.muted)),
                      )
                    : Column(
                        children: [
                          for (final f in items)
                            Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ExpansionTile(
                                title: Text(
                                    str(f['question'] ??
                                        f['question_ar'] ??
                                        f['title']),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 0, 16, 16),
                                    child: Text(
                                        str(f['answer'] ??
                                            f['answer_ar'] ??
                                            f['body']),
                                        style: const TextStyle(
                                            color: SahelColors.muted,
                                            height: 1.5)),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _subject,
              decoration: const InputDecoration(
                labelText: 'الموضوع',
                hintText: 'مثال: مشكلة في الدفع',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                hintText: 'name@example.com',
                prefixIcon: Icon(Icons.alternate_email),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _message,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'أرسل رسالتك إلينا',
                alignLabelWithHint: true,
                hintText: 'وصف موجز للمشكلة أو الاستفسار...',
              ),
            ),
            const SizedBox(height: 12),
            _sending
                ? const Center(child: CircularProgressIndicator())
                : SahelButton.gradient(
                    label: 'إرسال',
                    icon: Icons.send,
                    height: 48,
                    onPressed: _send,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _tile(IconData i, String t, String sub, {VoidCallback? onTap}) {
    // Material (not a decorated Container) so ListTile ink splashes stay
    // visible on top of the card colour.
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: SahelColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: SahelRadii.mdRadius,
          side: BorderSide(color: SahelColors.border),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Icon(i, color: SahelColors.primary600),
          title:
              Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(sub,
              style:
                  const TextStyle(color: SahelColors.muted, fontSize: 12)),
          trailing: const Icon(Icons.chevron_right,
              color: SahelColors.muted),
        ),
      ),
    );
  }
}
