import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/settings_provider.dart';
import '../../../shared/theme/sahel_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _group('العامة', [
              _tile(Icons.translate, 'اللغة', 'العربية',
                  () => context.push('/settings/language')),
              _tile(Icons.monetization_on_outlined, 'العملة',
                  ref.watch(appSettingsProvider).currency.toUpperCase(),
                  () => context.push('/settings/currency')),
            ]),
            _group('الخصوصية والأمان', [
              _tile(Icons.lock_outline, 'تغيير كلمة المرور', null,
                  () => _changePassword(context, ref)),
              _tile(Icons.delete_outline, 'حذف الحساب', null,
                  () => _deleteAccount(context, ref),
                  danger: true),
            ]),
            _group('الحساب', [
              _tile(Icons.logout, 'تسجيل الخروج', null,
                  () => _logout(context, ref),
                  danger: true),
            ]),
            const SizedBox(height: 24),
            const Center(
              child: Text('Sahel v1.0.0',
                  style: TextStyle(color: SahelColors.muted, fontSize: 12)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('خروج',
                  style: TextStyle(color: SahelColors.red600))),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authNotifierProvider.notifier).logout();
      if (context.mounted) context.go('/login');
    }
  }

  Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: current,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'كلمة المرور الحالية')),
            const SizedBox(height: 12),
            TextField(
                controller: next,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'كلمة المرور الجديدة')),
            const SizedBox(height: 12),
            TextField(
                controller: confirm,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'تأكيد كلمة المرور')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حفظ')),
        ],
      ),
    );
    if (ok != true) return;
    if (next.text != confirm.text || next.text.length < 8) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('كلمة المرور يجب أن تكون 8 أحرف على الأقل ومتطابقة')));
      }
      return;
    }
    try {
      await ref
          .read(customerRepositoryProvider)
          .changePassword(current.text, next.text, confirm.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تم تغيير كلمة المرور بنجاح')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تعذر تغيير كلمة المرور — تحقق من الحالية')));
      }
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final password = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'هذا الإجراء نهائي ولا يمكن التراجع عنه. أدخل كلمة المرور للتأكيد.'),
            const SizedBox(height: 12),
            TextField(
                controller: password,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'كلمة المرور')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حذف نهائي',
                  style: TextStyle(color: SahelColors.red600))),
        ],
      ),
    );
    if (ok != true || password.text.isEmpty) return;
    try {
      await ref
          .read(customerRepositoryProvider)
          .destroyAccount(password.text);
      await ref.read(authNotifierProvider.notifier).logout();
      if (context.mounted) context.go('/login');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تعذر حذف الحساب — تحقق من كلمة المرور')));
      }
    }
  }

  Widget _group(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  color: SahelColors.muted,
                  fontWeight: FontWeight.w700)),
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

  Widget _tile(IconData i, String t, String? sub, VoidCallback onTap,
      {bool danger = false}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(i,
          color: danger ? SahelColors.red600 : SahelColors.primary600),
      title: Text(t,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: danger ? SahelColors.red600 : null)),
      subtitle: sub == null
          ? null
          : Text(sub,
              style:
                  const TextStyle(color: SahelColors.muted, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: SahelColors.muted),
      shape:
          const Border(bottom: BorderSide(color: SahelColors.slate100, width: 1)),
    );
  }
}
