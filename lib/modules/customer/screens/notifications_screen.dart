import 'package:flutter/material.dart';
import '../../../shared/theme/sahel_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _notif(Icons.check_circle, SahelColors.green600, 'تم قبول طلبك',
                'مزود الخدمة وافق على حجز #2024، يرجى التأكيد خلال 15 دقيقة.', 'الآن'),
            _notif(Icons.person_pin_circle_outlined, SahelColors.primary600, 'المزود قادم',
                'محمد الفني بدأ بالتوجه إليك، الوصول المتوقع خلال 10 دقائق.', '10 دقائق'),
            _notif(Icons.payments_outlined, SahelColors.amber500, 'تمت عملية دفع',
                'تم خصم 2,500 ﷼ من محفظتك مقابل الحجز #2024.', 'ساعة'),
          ],
        ),
      ),
    );
  }

  Widget _notif(IconData i, Color c, String t, String s, String time) {
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
