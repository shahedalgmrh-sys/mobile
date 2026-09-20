import 'package:flutter/material.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/shared/widgets/status_pill.dart';
import '../../../shared/theme/sahel_colors.dart';
import '../../../models/booking_status.dart';

class BookingRequestsFeedScreen extends StatelessWidget {
  const BookingRequestsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلبات الحجز')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _request('أحمد محمد', 'تنظيف منزل كامل', '20 سبتمبر · 10:00 صباحاً', 'صنعاء - حيلة', 2500, BookingStatus.pending),
            const SizedBox(height: 12),
            _request('خالد عبدالله', 'فحص تكييف 3 وحدات', '21 سبتمبر · 2:00 عصراً', 'صنعاء - السبعين', 3800, BookingStatus.pending),
            const SizedBox(height: 40),
            const Center(
              child: Text('لا توجد طلبات أخرى',
                  style: TextStyle(color: SahelColors.muted, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _request(String name, String svc, String time, String loc, double price, BookingStatus s) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SahelColors.slate200),
        boxShadow: const [BoxShadow(color: Color(0x0A0F172A), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(child: Text(name[0])),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(loc, style: const TextStyle(color: SahelColors.muted, fontSize: 12)),
                  ],
                ),
              ),
              BookingStatusPill(status: s),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SahelColors.slate50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.plumbing_sharp, color: SahelColors.primary600),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(svc, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(time, style: const TextStyle(color: SahelColors.muted, fontSize: 12)),
                    ],
                  ),
                ),
                Text('${price.toStringAsFixed(0)} ﷼',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: SahelColors.primary700, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SahelButton.soft(label: 'رفض', onTap: () {}, height: 40),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: SahelButton(label: 'قبول الطلب', variant: SahelButtonVariant.gradient, onPressed: () {}, height: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
