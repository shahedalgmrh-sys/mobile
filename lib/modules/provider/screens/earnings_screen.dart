import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/sahel_colors.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأرباح'),
        actions: [
          TextButton(onPressed: () => context.push('/p/withdraw'), child: const Text('سحب')),
        ],
      ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('الرصيد المتاح للسحب', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  SizedBox(height: 8),
                  Text('42,500 ﷼', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32)),
                  SizedBox(height: 20),
                  Text('هذا الشهر', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(child: Text('+12,450 ﷼', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                      Icon(Icons.trending_up, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _metric('الحجوزات', '128', SahelColors.primary600)),
                const SizedBox(width: 10),
                Expanded(child: _metric('منجز', '122', SahelColors.green600)),
                const SizedBox(width: 10),
                Expanded(child: _metric('ملغي', '6', SahelColors.red600)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('آخر العمليات', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            _txn('حجز #2050 - تنظيف', '20 سبتمبر', '+2,500 ﷼', SahelColors.green600),
            _txn('حجز #2049 - تكييف', '19 سبتمبر', '+3,800 ﷼', SahelColors.green600),
            _txn('سحب - بنك اليمن', '18 سبتمبر', '-10,000 ﷼', SahelColors.red600),
          ],
        ),
      ),
    );
  }

  Widget _metric(String l, String v, Color c) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SahelColors.slate200),
      ),
      child: Column(
        children: [
          Text(v, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: c)),
          const SizedBox(height: 4),
          Text(l, style: const TextStyle(fontSize: 11, color: SahelColors.muted)),
        ],
      ),
    );
  }

  Widget _txn(String t, String d, String a, Color c) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(d, style: const TextStyle(fontSize: 12, color: SahelColors.muted)),
              ],
            ),
          ),
          Text(a, style: TextStyle(fontWeight: FontWeight.w800, color: c)),
        ],
      ),
    );
  }
}
