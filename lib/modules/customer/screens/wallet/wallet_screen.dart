import 'package:flutter/material.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/core/constants/enums.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const balance = 5000.0;

    final transactions = [
      (
        type: 'add',
        title: 'شحن رصيد 1,000 ر.س',
        subtitle: '2026-09-18 14:20 · عبر STC Pay',
        amount: 1000.0,
      ),
      (
        type: 'payment',
        title: 'دفع حجز #BK-20260004 · تنظيف شقق',
        subtitle: '2026-09-17 09:15 · خدمة منزلية',
        amount: 1840.0,
      ),
      (
        type: 'refund',
        title: 'استرداد حجز ملغي',
        subtitle: '2026-09-15 16:40 · حجز #BK-20260002',
        amount: 500.0,
      ),
      (
        type: 'add',
        title: 'شحن رصيد 2,500 ر.س',
        subtitle: '2026-09-10 11:00 · عبر مدى',
        amount: 2500.0,
      ),
      (
        type: 'payment',
        title: 'دفع حجز #BK-20260001 · صيانة مكيفات',
        subtitle: '2026-09-05 13:30 · فني محمد',
        amount: 760.0,
      ),
      (
        type: 'refund',
        title: 'مكافأة دعوة صديق',
        subtitle: '2026-09-01 10:00 · برنامج الإحالات',
        amount: 200.0,
      ),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180),
        child: Container(
          decoration: BoxDecoration(gradient: SahelColors.nightGradient),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'رصيد المحفظة',
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    balance.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},'),
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
                  ),
                  const Text(
                    'ريال يمني (YER)',
                    style: TextStyle(fontSize: 15, color: SahelColors.primary200, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: SahelButton.gradient(
                  icon: Icons.add,
                  label: 'شحن الرصيد',
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SahelButton.soft(
                  icon: Icons.receipt_long,
                  label: 'كشف الحساب',
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('طرق الدفع المحفوظة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: SahelRadii.lgRadius,
              side: const BorderSide(color: SahelColors.border),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1A1F71), Color(0xFF6772E5)]),
                      borderRadius: SahelRadii.smRadius,
                    ),
                    child: const Icon(Icons.credit_card, color: Colors.white, size: 22),
                  ),
                  title: const Text('Visa •••• 4242', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: const Text('تاريخ الانتهاء: 08/2028', style: TextStyle(fontSize: 12, color: SahelColors.textMuted)),
                  trailing: Chip(
                    label: const Text('افتراضي', style: TextStyle(color: SahelColors.success, fontWeight: FontWeight.w800, fontSize: 11)),
                    backgroundColor: SahelColors.successSoft,
                    side: BorderSide.none,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF006F3E), Color(0xFF00A651)]),
                      borderRadius: SahelRadii.smRadius,
                    ),
                    child: const Icon(Icons.credit_card, color: Colors.white, size: 22),
                  ),
                  title: const Text('مدى •••• 8881', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: const Text('تاريخ الانتهاء: 03/2027', style: TextStyle(fontSize: 12, color: SahelColors.textMuted)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: SahelColors.primary50,
                      borderRadius: SahelRadii.smRadius,
                    ),
                    child: const Icon(Icons.add, color: SahelColors.primary700, size: 24),
                  ),
                  title: const Text('إضافة بطاقة جديدة', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: SahelColors.primary700)),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text('آخر العمليات (30 يوماً)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('عرض الكل', style: TextStyle(color: SahelColors.primary700, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            primary: false,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final tx = transactions[i];
              final isAdd = tx.type == 'add' || tx.type == 'refund';
              final iconColor = tx.type == 'add'
                  ? SahelColors.success
                  : tx.type == 'payment'
                      ? SahelColors.danger
                      : SahelColors.info;
              final iconBg = tx.type == 'add'
                  ? SahelColors.successSoft
                  : tx.type == 'payment'
                      ? SahelColors.dangerSoft
                      : SahelColors.infoSoft;
              final icon = tx.type == 'add'
                  ? Icons.add
                  : tx.type == 'payment'
                      ? Icons.remove
                      : Icons.refresh;
              final prefix = isAdd ? '+' : '−';
              return Material(
                color: SahelColors.surface,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: SahelRadii.smRadius,
                      color: iconBg,
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  subtitle: Text(tx.subtitle, style: const TextStyle(fontSize: 11, color: SahelColors.textMuted)),
                  trailing: Text(
                    '$prefix${tx.amount.toStringAsFixed(0)} ر.س',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: iconColor),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

typedef _Tx = ({String type, String title, String subtitle, double amount});
