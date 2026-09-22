import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import '../../../shared/theme/sahel_colors.dart';

class ProviderSettingsScreen extends ConsumerWidget {
  const ProviderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final profile = ref.watch(providerProfileProvider).valueOrNull;
    final user = auth.user ?? const <String, dynamic>{};
    final businessName = str(
        profile?['business_name'] ?? user['name'], 'مزود ساحل');
    final contact = str(user['phone'] ?? user['email']);
    final isVerified = toBool(
        profile?['is_verified'] ??
            (str(profile?['verification_status']) == 'verified'));

    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الحساب')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF0D9488), Color(0xFF14B8A6)]),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              accountName: Text(businessName,
                  style:
                      const TextStyle(fontWeight: FontWeight.w700)),
              accountEmail: Text(
                  '$contact${isVerified ? ' · موثق' : ''}'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                    businessName.isNotEmpty ? businessName[0] : 'س',
                    style: const TextStyle(
                        color: SahelColors.primary700,
                        fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 16),
            _g('الملف التجاري', [
              _t(Icons.badge_outlined, 'المعلومات الأساسية', () {}),
              _t(Icons.verified_user_outlined, 'التحقق (KYC)',
                  () => context.push('/p/kyc')),
              _t(Icons.photo_library_outlined, 'صور الأعمال', () {}),
              _t(Icons.category_outlined, 'تصنيفات الخدمات',
                  () => context.push('/p/services')),
            ]),
            _g('العمليات', [
              _t(Icons.event_available_outlined, 'ساعات العمل',
                  () => context.push('/p/calendar')),
              _t(Icons.notifications_active_outlined,
                  'إشعارات الطلبات',
                  () => context.push('/p/notifications')),
              _t(Icons.location_on_outlined, 'مناطق الخدمة', () {}),
              _t(Icons.account_balance_wallet_outlined, 'السحوبات',
                  () => context.push('/p/withdraw')),
            ]),
            _g('الحساب', [
              _t(Icons.logout_outlined, 'تسجيل الخروج', () async {
                await ref
                    .read(authNotifierProvider.notifier)
                    .logout();
              }),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _g(String t, List<Widget> c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
          child: Text(t,
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
          child: Column(children: c),
        ),
      ],
    );
  }

  Widget _t(IconData i, String l, VoidCallback onTap) {
    return ListTile(
      leading: Icon(i, color: SahelColors.primary600),
      title: Text(l, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing:
          const Icon(Icons.chevron_right, color: SahelColors.muted),
      onTap: onTap,
      shape: Border(
          bottom: BorderSide(color: SahelColors.slate100, width: 1)),
    );
  }
}
