import 'package:flutter/material.dart';
import '../../../shared/widgets/booking_stepper.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import '../../../models/booking_status.dart';
import '../../../shared/theme/sahel_colors.dart';

class ProviderBookingDetailsScreen extends StatelessWidget {
  final String id;

  const ProviderBookingDetailsScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الحجز #$id')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BookingStatusStepper(status: BookingStatus.accepted),
            const SizedBox(height: 24),
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('تفاصيل الخدمة',
                      style: TextStyle(color: SahelColors.muted, fontSize: 12, fontWeight: FontWeight.w700)),
                  SizedBox(height: 6),
                  Text('تنظيف منزل كامل (5 غرف)',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  SizedBox(height: 10),
                  Text('20 سبتمبر · 10:00 صباحاً · 4 ساعات تقريباً',
                      style: TextStyle(color: SahelColors.muted, fontSize: 13)),
                  SizedBox(height: 6),
                  Text('شارع حيلة، صنعاء، اليمن',
                      style: TextStyle(color: SahelColors.muted, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('العميل',
                      style: TextStyle(color: SahelColors.muted, fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      CircleAvatar(child: Text('أ')),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('أحمد محمد', style: TextStyle(fontWeight: FontWeight.w700)),
                            Text('+967 777 123 456', style: TextStyle(color: SahelColors.muted, fontSize: 12)),
                          ],
                        ),
                      ),
                      CircleAvatar(backgroundColor: SahelColors.primary100,
                          child: Icon(Icons.phone, color: SahelColors.primary700, size: 18)),
                      SizedBox(width: 8),
                      CircleAvatar(backgroundColor: SahelColors.primary100,
                          child: Icon(Icons.chat_bubble, color: SahelColors.primary700, size: 18)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _card(
              Row(
                children: const [
                  Text('المبلغ المستحق', style: TextStyle(color: SahelColors.muted)),
                  Spacer(),
                  Text('2,500 ﷼',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: SahelColors.primary700)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SahelButton.soft(label: 'رفض الحجز', onTap: () {}, height: 46),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SahelButton(label: 'قبول', variant: SahelButtonVariant.gradient, onPressed: () {}, height: 46),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SahelButton(label: 'بدء التنفيذ', variant: SahelButtonVariant.amber, onPressed: () {}, height: 46),
            const SizedBox(height: 10),
            SahelButton(label: 'إنهاء الحجز', variant: SahelButtonVariant.filled, onPressed: () {}, height: 46),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SahelColors.slate200),
      ),
      child: child,
    );
  }
}
