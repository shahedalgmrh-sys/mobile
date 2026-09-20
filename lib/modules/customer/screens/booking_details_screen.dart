import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/booking_stepper.dart';
import '../../../shared/widgets/provider_mini_card.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import '../../../models/provider.dart';
import '../../../models/booking_status.dart';
import '../../../shared/theme/sahel_colors.dart';

class BookingDetailsScreen extends StatelessWidget {
  final String id;

  const BookingDetailsScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final p = ProviderModel(
      id: 'p1',
      userId: 'u1',
      businessName: 'فريق ساحل للتنظيف',
      ratingAvg: 4.9,
      totalReviews: 312,
      isVerified: true,
    );
    return Scaffold(
      appBar: AppBar(title: Text('تفاصيل الحجز #$id')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BookingStatusStepper(status: BookingStatus.inProgress),
            const SizedBox(height: 24),
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الخدمة',
                      style: TextStyle(fontWeight: FontWeight.w700, color: SahelColors.muted, fontSize: 12)),
                  const SizedBox(height: 6),
                  const Text('تنظيف منزل كامل',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(Icons.calendar_month, size: 16, color: SahelColors.muted),
                      SizedBox(width: 6),
                      Text('20 سبتمبر 2026 · 10:00 صباحاً',
                          style: TextStyle(color: SahelColors.muted, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Icon(Icons.location_on, size: 16, color: SahelColors.muted),
                      SizedBox(width: 6),
                      Expanded(
                          child: Text('شارع حيلة، صنعاء، اليمن',
                              style: TextStyle(color: SahelColors.muted, fontSize: 13))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('مزود الخدمة',
                      style: TextStyle(fontWeight: FontWeight.w700, color: SahelColors.muted, fontSize: 12)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => context.push('/providers/${p.id}'),
                    child: ProviderMiniCard(p: p),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SahelButton.soft(
                          label: 'محادثة',
                          onTap: () => context.push('/inbox/thread_$id'),
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SahelButton(
                          label: 'اتصال',
                          variant: SahelButtonVariant.outline,
                          onPressed: () {},
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _card(
              Row(
                children: [
                  const Text('المجموع',
                      style: TextStyle(fontSize: 14, color: SahelColors.muted)),
                  const Spacer(),
                  const Text('2,500 ﷼',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: SahelColors.primary700)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SahelButton.soft(
                    label: 'تتبع الحجز',
                    onTap: () => context.push('/bookings/$id/track'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SahelButton(
                    label: 'تقييم الخدمة',
                    variant: SahelButtonVariant.amber,
                    onPressed: () => context.push('/bookings/$id/review'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SahelButton.soft(
              label: 'إبلاغ عن مشكلة',
              onTap: () => context.push('/bookings/$id/complaint'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SahelColors.slate200),
      ),
      child: child,
    );
  }
}
