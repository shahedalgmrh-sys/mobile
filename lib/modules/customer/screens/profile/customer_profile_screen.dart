import 'package:flutter/material.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/status_pill.dart';
import '../bookings/bookings_list_screen.dart';
import 'package:saber_flutter/core/constants/enums.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const name = 'آمال أحمد عبدالله';
    const phone = '+967 777 123 456';
    const isVerified = true;

    final tiles = [
      (icon: Icons.schedule, title: 'حجوزاتي', subtitle: '24 حجز', onTap: (ctx) {
        Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const BookingsListScreen()));
      }),
      (icon: Icons.reviews, title: 'تقييماتي', subtitle: '12 تقييم', onTap: (_) {}),
      (icon: Icons.favorite, title: 'المفضلة', subtitle: '12 خدمة', onTap: (_) {}),
      (icon: Icons.account_balance_wallet, title: 'المحفظة', subtitle: '5,000 ر.س', onTap: (_) {}),
      (icon: Icons.local_offer, title: 'الكوبونات والعروض', subtitle: '3 كوبونات', onTap: (_) {}),
      (icon: Icons.location_on, title: 'عناويني', subtitle: '3 عناوين', onTap: (_) {}),
      (icon: Icons.notifications, title: 'الإشعارات', subtitle: '4 جديدة', onTap: (_) {}),
      (icon: Icons.language, title: 'اللغة', subtitle: 'العربية', onTap: (_) {}),
      (icon: Icons.monetization_on, title: 'إعدادات العملة', subtitle: 'ريال يمني', onTap: (_) {}),
      (icon: Icons.security, title: 'الأمان وتغيير كلمة المرور', subtitle: null, onTap: (_) {}),
      (icon: Icons.support_agent, title: 'مركز الدعم والمساعدة', subtitle: null, onTap: (_) {}),
      (icon: Icons.card_giftcard, title: 'دعوة الأصدقاء', subtitle: 'احصل على 50 ر.س', onTap: (_) {}),
      (icon: Icons.logout, title: 'تسجيل الخروج', subtitle: null, onTap: (ctx) => _showLogoutConfirm(ctx)),
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
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.settings, color: Colors.white),
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
                  shape: RoundedRectangleBorder(borderRadius: SahelRadii.lgRadius),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: SahelColors.primary100,
                          child: const Icon(Icons.person, color: SahelColors.primary700, size: 40),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                name,
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                phone,
                                style: const TextStyle(color: SahelColors.textMuted, fontSize: 13),
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
                Expanded(
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: SahelRadii.mdRadius, side: const BorderSide(color: SahelColors.border)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const Text('حجوزاتي', style: TextStyle(fontSize: 11, color: SahelColors.textMuted)),
                          const SizedBox(height: 4),
                          const Text('24', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: SahelColors.primary700)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: SahelRadii.mdRadius, side: const BorderSide(color: SahelColors.border)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const Text('المحفظة', style: TextStyle(fontSize: 11, color: SahelColors.textMuted)),
                          const SizedBox(height: 4),
                          const Text('5,000', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: SahelColors.amber)),
                          const Text('YER', style: TextStyle(fontSize: 10, color: SahelColors.textMuted, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: SahelRadii.mdRadius, side: const BorderSide(color: SahelColors.border)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const Text('المفضلة', style: TextStyle(fontSize: 11, color: SahelColors.textMuted)),
                          const SizedBox(height: 4),
                          const Text('12', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: SahelColors.violet)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('إعدادت الحساب', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
                        color: t.title == 'تسجيل الخروج' ? SahelColors.dangerSoft : SahelColors.primary50,
                        borderRadius: SahelRadii.smRadius,
                      ),
                      child: Icon(
                        t.icon,
                        color: t.title == 'تسجيل الخروج' ? SahelColors.danger : SahelColors.primary600,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      t.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: t.title == 'تسجيل الخروج' ? SahelColors.danger : SahelColors.text,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: t.subtitle != null
                        ? Text(t.subtitle!, style: const TextStyle(fontSize: 11, color: SahelColors.textMuted))
                        : null,
                    trailing: const Icon(Icons.chevron_right, color: SahelColors.textMuted, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    onTap: () => t.onTap(context),
                    shape: RoundedRectangleBorder(borderRadius: SahelRadii.mdRadius),
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

  void _showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: SahelRadii.lgRadius),
        title: const Row(
          children: [
            Icon(Icons.logout, color: SahelColors.danger),
            SizedBox(width: 8),
            Text('تأكيد الخروج', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء', style: TextStyle(color: SahelColors.textMuted, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SahelColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: SahelRadii.pillRadius),
            ),
            child: const Text('خروج', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

typedef _Tile = ({IconData icon, String title, String? subtitle, void Function(BuildContext) onTap});
