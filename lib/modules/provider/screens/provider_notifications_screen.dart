import 'package:flutter/material.dart';
import '../../../shared/theme/sahel_colors.dart';

class ProviderNotificationsScreen extends StatelessWidget {
  const ProviderNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _n(Icons.add_task, SahelColors.green600, 'حجز جديد',
                'لديك طلب حجز جديد - تنظيف منزلي. تفاصيل الحجز #2060', 'الآن'),
            _n(Icons.reviews_outlined, SahelColors.amber500, 'تقييم جديد',
                'أحمد محمد أضاف تقييم 5 نجوم على خدمتك.', 'منذ ساعة'),
            _n(Icons.payments_outlined, SahelColors.primary600, 'وصول رصيد',
                'تم إضافة 2,500 ﷼ إلى رصيدك بعد إتمام الحجز.', '3 ساعات'),
          ],
        ),
      ),
    );
  }

  Widget _n(IconData i, Color c, String t, String s, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SahelColors.slate200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 20, backgroundColor: c.withOpacity(0.12), child: Icon(i, color: c)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700))),
                    Text(time, style: const TextStyle(fontSize: 11, color: SahelColors.muted)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(s, style: const TextStyle(color: SahelColors.muted, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
