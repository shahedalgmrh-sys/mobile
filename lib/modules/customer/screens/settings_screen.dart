import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/sahel_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _group('العامة', [
              _tile(Icons.translate, 'اللغة', 'العربية', () => context.push('/settings/language')),
              _tile(Icons.monetization_on_outlined, 'العملة', '﷼ ريال يمني', () => context.push('/settings/currency')),
              _tile(Icons.location_city_outlined, 'المدينة الافتراضية', 'صنعاء', () {}),
              _tile(Icons.dark_mode_outlined, 'الوضع الليلي', 'مفعل', () {}),
            ]),
            _group('الإشعارات', [
              _tile(Icons.notifications_active_outlined, 'إشعارات الطلبات', null, () {}),
              _tile(Icons.offline_bolt_outlined, 'العروض والتخفيضات', null, () {}),
              _tile(Icons.message_outlined, 'إشعارات الرسائل', null, () {}),
            ]),
            _group('الخصوصية والأمان', [
              _tile(Icons.lock_outline, 'تغيير كلمة المرور', null, () {}),
              _tile(Icons.fingerprint_outlined, 'تسجيل الدخول بالبصمة', null, () {}),
              _tile(Icons.delete_outline, 'حذف الحساب', null, () {}),
            ]),
            const SizedBox(height: 24),
            const Center(
              child: Text('Sahel v1.0.0 build 421',
                  style: TextStyle(color: SahelColors.muted, fontSize: 12)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _group(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
          child: Text(title, style: const TextStyle(fontSize: 12, color: SahelColors.muted, fontWeight: FontWeight.w700)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: SahelColors.slate200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _tile(IconData i, String t, String? sub, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(i, color: SahelColors.primary600),
      title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: sub == null
          ? null
          : Text(sub, style: const TextStyle(color: SahelColors.muted, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: SahelColors.muted),
      shape: Border(bottom: BorderSide(color: SahelColors.slate100, width: 1)),
    );
  }
}
