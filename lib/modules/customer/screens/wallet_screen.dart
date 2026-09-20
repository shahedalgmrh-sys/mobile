import 'package:flutter/material.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import '../../../shared/theme/sahel_colors.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المحفظة')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF14B8A6)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0x4014B8A6), blurRadius: 24, offset: Offset(0, 8))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('الرصيد الحالي', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Text('15,250 ﷼',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                  SizedBox(height: 24),
                  Text('SAHEL WALLET',
                      style: TextStyle(color: Colors.white, letterSpacing: 3, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _tileBtn(Icons.add_circle_outline, 'شحن'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _tileBtn(Icons.send_outlined, 'تحويل'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _tileBtn(Icons.receipt_long_outlined, 'تفاصيل'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('آخر العمليات',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            _txn(Icons.add, SahelColors.green600, 'شحن رصيد', 'بطاقة مدى', '+1,000 ﷼', 'اليوم'),
            _txn(Icons.remove, SahelColors.red600, 'دفع حجز #2024', 'تنظيف منزلي', '-2,500 ﷼', 'أمس'),
            _txn(Icons.add, SahelColors.green600, 'استرداد', 'إلغاء حجز', '+500 ﷼', 'منذ 3 أيام'),
            const SizedBox(height: 12),
            SahelButton.soft(label: 'عرض كل العمليات', onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _tileBtn(IconData i, String t) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SahelColors.slate200),
      ),
      child: Column(
        children: [Icon(i, color: SahelColors.primary600), const SizedBox(height: 6), Text(t, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))],
      ),
    );
  }

  Widget _txn(IconData i, Color c, String title, String sub, String amt, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SahelColors.slate200),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 18, backgroundColor: c.withOpacity(0.12), child: Icon(i, color: c)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(color: SahelColors.muted, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amt, style: TextStyle(fontWeight: FontWeight.w800, color: c)),
              const SizedBox(height: 2),
              Text(time, style: const TextStyle(color: SahelColors.muted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
