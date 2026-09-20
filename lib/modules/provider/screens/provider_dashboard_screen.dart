import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/sahel_colors.dart';

class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(onPressed: () => context.push('/p/notifications'), icon: const Icon(Icons.notifications_outlined)),
          IconButton(onPressed: () => context.push('/p/settings'), icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF14B8A6)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Color(0x4014B8A6), blurRadius: 24, offset: Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الأرباح الشهرية', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  const Text('85,420 ﷼', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 30)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _miniStat('الحجوزات', '128', Icons.calendar_month),
                      const SizedBox(width: 12),
                      _miniStat('التقييم', '4.9', Icons.star),
                      const SizedBox(width: 12),
                      _miniStat('جديدة', '12', Icons.bolt),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _card(Icons.list_alt, 'قائمة الخدمات', () => context.push('/p/services'))),
                const SizedBox(width: 10),
                Expanded(child: _card(Icons.calendar_today, 'التقويم', () => context.push('/p/calendar'))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _card(Icons.account_balance_wallet_outlined, 'سحب الرصيد', () => context.push('/p/withdraw'))),
                const SizedBox(width: 10),
                Expanded(child: _card(Icons.verified_user_outlined, 'حالة KYC', () => context.push('/p/kyc'))),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: const [
                Expanded(child: Text('أحدث الحجوزات', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                Text('عرض الكل', style: TextStyle(color: SahelColors.primary600, fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => context.push('/p/bookings/b1'),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: SahelColors.slate200),
                ),
                child: Row(
                  children: [
                    Container(width: 4, height: 50, decoration: BoxDecoration(color: SahelColors.amber500, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('طلب جديد - تنظيف عميق', style: TextStyle(fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text('أحمد محمد · صنعاء · 20 سبتمبر', style: TextStyle(color: SahelColors.muted, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text('2,500 ﷼', style: TextStyle(color: SahelColors.primary700, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String l, String v, IconData i) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Icon(i, size: 16, color: Colors.white),
            const SizedBox(height: 4),
            Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            Text(l, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _card(IconData i, String t, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SahelColors.slate200),
        ),
        child: Column(
          children: [
            Icon(i, size: 32, color: SahelColors.primary600),
            const SizedBox(height: 8),
            Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: SahelColors.text)),
          ],
        ),
      ),
    );
  }
}
