import 'package:flutter/material.dart';
import '../../../shared/theme/sahel_colors.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الدعم والمساعدة')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF14B8A6)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent, size: 44, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('فريق الدعم متاح 24/7',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('متوسط وقت الرد: أقل من 5 دقائق',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _tile(Icons.chat_outlined, 'محادثة مباشرة', 'تواصل مع فريق الدعم فوراً'),
            _tile(Icons.phone_outlined, 'اتصال', '+967 1 234 567'),
            _tile(Icons.email_outlined, 'البريد الإلكتروني', 'support@sahel.app'),
            _tile(Icons.help_outline, 'الأسئلة الشائعة', 'إجابات لأكثر الاستفسارات شيوعاً'),
            const SizedBox(height: 24),
            const TextField(
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'أرسل رسالتك إلينا',
                alignLabelWithHint: true,
                hintText: 'وصف موجز للمشكلة أو الاستفسار...',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.send),
              label: const Text('إرسال'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: SahelColors.primary600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(IconData i, String t, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SahelColors.slate200),
      ),
      child: ListTile(
        leading: Icon(i, color: SahelColors.primary600),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(sub, style: const TextStyle(color: SahelColors.muted, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: SahelColors.muted),
      ),
    );
  }
}
