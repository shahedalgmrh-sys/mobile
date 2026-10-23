import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saber_flutter/core/errors/failures.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
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

    // Grouped settings sections matching Stitch reference _6.
    final activityTiles = <_ProfileTile>[
      _ProfileTile(
          icon: Icons.schedule,
          title: 'حجوزاتي',
          subtitle: '${fmtCount(bookingsCount)} حجز',
          onTap: (ctx) => ctx.go('/bookings')),
      _ProfileTile(
          icon: Icons.reviews,
          title: 'تقييماتي',
          onTap: (ctx) => ctx.push('/profile/reviews')),
      _ProfileTile(
          icon: Icons.favorite,
          title: 'المفضلة',
          subtitle: '${fmtCount(favCount)} عنصر',
          onTap: (ctx) => ctx.push('/home/favorites')),
      _ProfileTile(
          icon: Icons.location_on,
          title: 'عناويني',
          onTap: (ctx) => ctx.push('/addresses')),
    ];
    final paymentTiles = <_ProfileTile>[
      _ProfileTile(
          icon: Icons.account_balance_wallet,
          title: 'المحفظة',
          subtitle: walletBalance,
          onTap: (ctx) => ctx.push('/wallet')),
      _ProfileTile(
          icon: Icons.receipt_long,
          title: 'المدفوعات والفوترة',
          subtitle: 'سجل المدفوعات والفواتير',
          onTap: (ctx) => ctx.push('/payments')),
      _ProfileTile(
          icon: Icons.local_offer,
          title: 'الكوبونات والعروض',
          onTap: (ctx) => ctx.push('/profile/coupons')),
    ];
    final settingsTiles = <_ProfileTile>[
      _ProfileTile(
          icon: Icons.notifications,
          title: 'الإشعارات',
          onTap: (ctx) => ctx.push('/notifications')),
      _ProfileTile(
          icon: Icons.language,
          title: 'اللغة',
          subtitle: 'العربية',
          onTap: (ctx) => ctx.push('/settings/language')),
      _ProfileTile(
          icon: Icons.monetization_on,
          title: 'إعدادات العملة',
          onTap: (ctx) => ctx.push('/settings/currency')),
      _ProfileTile(
          icon: Icons.security,
          title: 'الأمان وتغيير كلمة المرور',
          onTap: (ctx) => ctx.push('/settings')),
    ];
    final helpTiles = <_ProfileTile>[
      _ProfileTile(
          icon: Icons.support_agent,
          title: 'مركز الدعم والمساعدة',
          onTap: (ctx) => ctx.push('/support')),
      _ProfileTile(
          icon: Icons.gavel,
          title: 'شكاواي',
          subtitle: 'سجل الشكاوى وردود الدعم',
          onTap: (ctx) => ctx.push('/profile/complaints')),
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
                decoration: const BoxDecoration(
                  gradient: SahelColors.primaryGradient,
                  borderRadius: BorderRadius.only(
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
                                  color: SahelColors.onPrimary),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => context.push('/settings'),
                              icon: const Icon(Icons.settings,
                                  color: SahelColors.onPrimary),
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
                  shadowColor: SahelColors.text.withValues(alpha: 0.12),
                  margin: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                      borderRadius: SahelRadii.lgRadius),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showAvatarSheet(context, ref),
                          child: Stack(
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
                                        color: SahelColors.primary700,
                                        size: 40)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: SahelColors.primary600,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: SahelColors.onPrimary, width: 2),
                                  ),
                                  child: const Icon(Icons.photo_camera,
                                      color: SahelColors.onPrimary, size: 12),
                                ),
                              ),
                            ],
                          ),
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
          const SizedBox(height: 24),
          _ProfileSection(
              title: 'الخدمات والنشاط', tiles: activityTiles),
          _ProfileSection(
              title: 'الدفع والمحفظة', tiles: paymentTiles),
          _ProfileSection(
              title: 'الإعدادات', tiles: settingsTiles),
          _ProfileSection(
              title: 'المساعدة', tiles: helpTiles),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutConfirm(context, ref),
                icon: const Icon(Icons.logout, color: SahelColors.danger),
                label: const Text('تسجيل الخروج',
                    style: TextStyle(
                        color: SahelColors.danger,
                        fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  backgroundColor: SahelColors.dangerSoft,
                  side: BorderSide(color: SahelColors.danger.withValues(alpha: 0.3)),
                  shape: const RoundedRectangleBorder(
                      borderRadius: SahelRadii.mdRadius),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'ساحل • نسخة 1.0.0',
                style: TextStyle(
                    fontSize: 12,
                    color: SahelColors.textSoft,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
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
        shape: const RoundedRectangleBorder(
            borderRadius: SahelRadii.mdRadius,
            side: BorderSide(color: SahelColors.border)),
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

  /// Jumps to `/customer/me/avatar` — pick → multipart upload → refresh auth
  /// user. Mirrors the web profile settings behavior.
  void _showAvatarSheet(BuildContext context, WidgetRef ref) {
    final hasAvatar = strOrNull(
            ref.read(authNotifierProvider).user?['avatar']) !=
        null;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text('الصورة الشخصية',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library_outlined),
              title: const Text('اختيار من المعرض'),
              onTap: () {
                Navigator.pop(ctx);
                _uploadAvatar(context, ref, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('كالتقاط صورة'),
              onTap: () {
                Navigator.pop(ctx);
                _uploadAvatar(context, ref, ImageSource.camera);
              },
            ),
            if (hasAvatar)
              ListTile(
                leading: const Icon(Icons.delete_outline,
                    color: SahelColors.danger),
                title: const Text('إزالة الصورة',
                    style: TextStyle(color: SahelColors.danger)),
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteAvatar(context, ref);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadAvatar(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    // Show pick dialog first; permissions handled inside image_picker.
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (picked == null || !context.mounted) return;

    _snack(context, 'جاري رفع الصورة…');
    try {
      await ref
          .read(customerRepositoryProvider)
          .updateAvatar(picked.path);
      await ref.read(authNotifierProvider.notifier).refreshUser();
      if (context.mounted) _snack(context, 'تم تحديث الصورة الشخصية ✓');
    } catch (e) {
      if (context.mounted) {
        _snack(context, _avatarFailureMessage(e, 'تعذر رفع الصورة'),
            error: true);
      }
    }
  }

  Future<void> _deleteAvatar(BuildContext context, WidgetRef ref) async {
    _snack(context, 'جاري إزالة الصورة…');
    try {
      await ref.read(customerRepositoryProvider).deleteAvatar();
      await ref.read(authNotifierProvider.notifier).refreshUser();
      if (context.mounted) _snack(context, 'تمت إزالة الصورة ✓');
    } catch (e) {
      if (context.mounted) {
        _snack(context, _avatarFailureMessage(e, 'تعذر إزالة الصورة'),
            error: true);
      }
    }
  }

  static void _snack(BuildContext context, String message,
      {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: error ? SahelColors.danger : null,
      ));
  }

  static String _avatarFailureMessage(Object e, String fallback) {
    if (e is ApiException) {
      final f = e.failure;
      if (f is ValidationFailure) {
        final first = f.errors.values.expand((v) => v).firstOrNull;
        if (first != null) return first;
      }
      if (f is ServerFailure) return f.message;
    }
    return fallback;
  }

  void _showLogoutConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: SahelRadii.lgRadius),
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
              foregroundColor: SahelColors.onPrimary,
              shape: const RoundedRectangleBorder(
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

/// Data model for a single profile settings row.
class _ProfileTile {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final void Function(BuildContext) onTap;
}

/// A grouped settings section with a muted header and a bordered card
/// containing the tiles, matching the Stitch reference _6 layout.
class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.tiles});

  final String title;
  final List<_ProfileTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: SahelColors.textMuted,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: SahelColors.surface,
              borderRadius: SahelRadii.mdRadius,
              border: Border.all(color: SahelColors.border),
            ),
            child: Column(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  _ProfileTileRow(tile: tiles[i]),
                  if (i < tiles.length - 1)
                    const Divider(height: 1, indent: 56),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTileRow extends StatelessWidget {
  const _ProfileTileRow({required this.tile});
  final _ProfileTile tile;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: SahelRadii.mdRadius,
        onTap: () => tile.onTap(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: SahelColors.primary50,
                  borderRadius: SahelRadii.smRadius,
                ),
                child: Icon(tile.icon,
                    color: SahelColors.primary600, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tile.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: SahelColors.text,
                            fontSize: 14)),
                    if (tile.subtitle != null)
                      Text(tile.subtitle!,
                          style: const TextStyle(
                              fontSize: 11,
                              color: SahelColors.textMuted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: SahelColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
