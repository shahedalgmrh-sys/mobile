import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/status_pill.dart';

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final wallet = ref.watch(customerWalletProvider).valueOrNull;
    final bookings = ref.watch(customerBookingsProvider(null)).valueOrNull;
    final favorites = ref.watch(customerFavoritesProvider).valueOrNull;

    final user = auth.user ?? const <String, dynamic>{};
    final name = str(user['name'], 'مستخدم ساحل');
    final phone = str(user['phone'] ?? user['email']);
    final isVerified = auth.isVerified;
    final walletBalance =
        str(wallet?['formatted_balance'] ?? wallet?['balance'], '—');
    final walletCurrency =
        str(wallet?['currency'] ?? wallet?['display_currency']).toUpperCase();
    final bookingsCount = bookings?.length;
    final favCount = favorites == null
        ? null
        : (dataList(favorites['services']).length +
            dataList(favorites['providers']).length);

    String fmtCount(int? v) => v == null ? '—' : '$v';

    final tiles = <({
      IconData icon,
      String title,
      String? subtitle,
      void Function(BuildContext) onTap,
    })>[
      (
        icon: Icons.schedule,
        title: 'حجوزاتي',
        subtitle: '${fmtCount(bookingsCount)} حجز',
        onTap: (ctx) => ctx.go('/bookings'),
      ),
      (
        icon: Icons.reviews,
        title: 'تقييماتي',
        subtitle: null,
        onTap: (ctx) => ctx.push('/profile/reviews'),
      ),
      (
        icon: Icons.favorite,
        title: 'المفضلة',
        subtitle: '${fmtCount(favCount)} عنصر',
        onTap: (ctx) => ctx.push('/home/favorites'),
      ),
      (
        icon: Icons.account_balance_wallet,
        title: 'المحفظة',
        subtitle: walletBalance,
        onTap: (ctx) => ctx.push('/wallet'),
      ),
      (
        icon: Icons.local_offer,
        title: 'الكوبونات والعروض',
        subtitle: null,
        onTap: (ctx) => ctx.push('/profile/coupons'),
      ),
      (
        icon: Icons.location_on,
        title: 'عناويني',
        subtitle: null,
        onTap: (ctx) => ctx.push('/addresses'),
      ),
      (
        icon: Icons.notifications,
        title: 'الإشعارات',
        subtitle: null,
        onTap: (ctx) => ctx.push('/notifications'),
      ),
      (
        icon: Icons.language,
        title: 'اللغة',
        subtitle: 'العربية',
        onTap: (ctx) => ctx.push('/settings/language'),
      ),
      (
        icon: Icons.monetization_on,
        title: 'إعدادات العملة',
        subtitle: null,
        onTap: (ctx) => ctx.push('/settings/currency'),
      ),
      (
        icon: Icons.security,
        title: 'الأمان وتغيير كلمة المرور',
        subtitle: null,
        onTap: (ctx) => ctx.push('/settings'),
      ),
      (
        icon: Icons.support_agent,
        title: 'مركز الدعم والمساعدة',
        subtitle: null,
        onTap: (ctx) => ctx.push('/support'),
      ),
      (
        icon: Icons.logout,
        title: 'تسجيل الخروج',
        subtitle: null,
        onTap: (ctx) => _showLogoutConfirm(ctx, ref),
      ),
    ];

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: SahelColors.nightGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              'حسابي',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => context.push('/settings'),
                              icon: const Icon(Icons.settings,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: -40,
                child: Card(
                  elevation: 6,
                  shadowColor: SahelColors.text.withOpacity(0.12),
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: SahelRadii.lgRadius),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: SahelColors.primary100,
                          backgroundImage:
                              strOrNull(user['avatar']) != null
                                  ? NetworkImage(str(user['avatar']))
                                  : null,
                          child: strOrNull(user['avatar']) == null
                              ? const Icon(Icons.person,
                                  color: SahelColors.primary700, size: 40)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                phone,
                                style: const TextStyle(
                                    color: SahelColors.textMuted,
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (isVerified)
                                    StatusPill.teal(text: 'حساب موثق'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 72),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _statCard('حجوزاتي', fmtCount(bookingsCount),
                    SahelColors.primary700),
                const SizedBox(width: 12),
                _statCard('المحفظة', walletBalance, SahelColors.amber,
                    unit: walletCurrency),
                const SizedBox(width: 12),
                _statCard('المفضلة', fmtCount(favCount), SahelColors.violet),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('إعدادت الحساب',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: List.generate(tiles.length, (i) {
                final t = tiles[i];
                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: t.title == 'تسجيل الخروج'
                            ? SahelColors.dangerSoft
                            : SahelColors.primary50,
                        borderRadius: SahelRadii.smRadius,
                      ),
                      child: Icon(
                        t.icon,
                        color: t.title == 'تسجيل الخروج'
                            ? SahelColors.danger
                            : SahelColors.primary600,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      t.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: t.title == 'تسجيل الخروج'
                            ? SahelColors.danger
                            : SahelColors.text,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: t.subtitle != null
                        ? Text(t.subtitle!,
                            style: const TextStyle(
                                fontSize: 11,
                                color: SahelColors.textMuted))
                        : null,
                    trailing: const Icon(Icons.chevron_right,
                        color: SahelColors.textMuted, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2),
                    onTap: () => t.onTap(context),
                    shape: RoundedRectangleBorder(
                        borderRadius: SahelRadii.mdRadius),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color,
      {String? unit}) {
    return Expanded(
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: SahelRadii.mdRadius,
            side: const BorderSide(color: SahelColors.border)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: SahelColors.textMuted)),
              const SizedBox(height: 4),
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: color)),
              if (unit != null && unit.isNotEmpty)
                Text(unit,
                    style: const TextStyle(
                        fontSize: 10,
                        color: SahelColors.textMuted,
                        fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: SahelRadii.lgRadius),
        title: const Row(
          children: [
            Icon(Icons.logout, color: SahelColors.danger),
            SizedBox(width: 8),
            Text('تأكيد الخروج',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content:
            const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء',
                style: TextStyle(
                    color: SahelColors.textMuted,
                    fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authNotifierProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SahelColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: SahelRadii.pillRadius),
            ),
            child: const Text('خروج',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
