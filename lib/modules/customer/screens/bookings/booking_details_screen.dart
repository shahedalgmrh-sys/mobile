import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/booking_status_pill.dart';
import 'package:saber_flutter/shared/widgets/booking_status_stepper.dart';
import 'package:saber_flutter/shared/widgets/provider_mini_card.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'live_tracking_screen.dart';
import 'package:saber_flutter/core/constants/enums.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const status = BookingStatus.inProgress;
    const scheduledAt = 'السبت 20 سبتمبر 2026 · 10:00 صباحاً';
    const addressFull = 'شارع الجزائر، حي الحصبة، صنعاء، اليمن، عمارة رقم 15، شقة رقم 3';
    const customerNotes = 'الرجاء جلب أدوات التنظيف الخاصة. البوابة الرئيسية مفتوحة.';
    const problemImageUrls = ['img1', 'img2', 'img3'];
    const subtotal = 1000.0;
    const discountPct = 0.20;
    const platformFeePct = 0.10;
    const vatPct = 0.15;
    final discount = subtotal * discountPct;
    final afterDiscount = subtotal - discount;
    final platformFee = afterDiscount * platformFeePct;
    final tax = (afterDiscount + platformFee) * vatPct;
    final total = afterDiscount + platformFee + tax;
    final isPaid = true;
    final cancellationAllowed = true;

    const titleSmall = TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SahelColors.text);
    const bodySmall = TextStyle(fontSize: 12, color: SahelColors.textMuted, fontWeight: FontWeight.w500);
    const muted = TextStyle(color: SahelColors.textMuted, fontWeight: FontWeight.w500, fontSize: 13);
    const amountStyle = TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: SahelColors.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تفاصيل الحجز #BK-20260919',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: BookingStatusPill(status: status),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const BookingStatusStepper(status: status),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: SahelRadii.lgRadius,
              side: const BorderSide(color: SahelColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('موعد التنفيذ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      const Spacer(),
                      const Text(
                        scheduledAt,
                        style: TextStyle(color: SahelColors.primary700, fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('الفني المكلف', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      const Spacer(),
                      const ProviderMiniCard(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: SahelColors.primary600, size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          addressFull,
                          style: TextStyle(fontSize: 13, height: 1.5, color: SahelColors.text),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('ملاحظات العميل:', style: titleSmall),
                  const SizedBox(height: 4),
                  const Text(customerNotes, style: bodySmall),
                  const SizedBox(height: 12),
                  const Text('صور المشكلة المرسلة:', style: titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: problemImageUrls.map((url) {
                      return Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: SahelColors.surface3,
                          borderRadius: SahelRadii.smRadius,
                          border: Border.all(color: SahelColors.border),
                        ),
                        child: const Icon(Icons.image, color: SahelColors.textMuted, size: 32),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text('الإجراءات السريعة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  Wrap(
                    runSpacing: 12,
                    spacing: 12,
                    children: [
                      SahelButton.gradient(
                        icon: Icons.map,
                        label: 'تتبع الوصول',
                        width: 150,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const LiveTrackingScreen()),
                          );
                        },
                      ),
                      SahelButton.soft(
                        icon: Icons.call,
                        label: 'اتصال',
                        width: 120,
                        onPressed: () async {
                          final tel = Uri.parse('tel:+967777123456');
                          if (await canLaunchUrl(tel)) await launchUrl(tel);
                        },
                      ),
                      SahelButton.soft(
                        icon: Icons.chat,
                        label: 'محادثة',
                        width: 120,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: SahelRadii.lgRadius,
              side: const BorderSide(color: SahelColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الفاتورة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [const Text('القيمة الأساسية', style: muted), const Spacer(), Text('${subtotal.toStringAsFixed(0)} ر.س', style: amountStyle)],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('الخصم -20%', style: muted),
                      const Spacer(),
                      Text('−${discount.toStringAsFixed(0)} ر.س', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: SahelColors.success)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [const Text('رسوم المنصة 10%', style: muted), const Spacer(), Text('${platformFee.toStringAsFixed(0)} ر.س', style: amountStyle)],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [const Text('الضريبة (VAT 15%)', style: muted), const Spacer(), Text('${tax.toStringAsFixed(0)} ر.س', style: amountStyle)],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('الإجمالي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      const Spacer(),
                      Text(
                        '${total.toStringAsFixed(0)} ر.س',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: SahelColors.primary700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: SahelColors.primary600, size: 20),
                      const SizedBox(width: 6),
                      const Text(
                        'طريقة الدفع: المحفظة',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SahelColors.text),
                      ),
                      const Spacer(),
                      Chip(
                        label: Text(
                          isPaid ? 'مدفوع ✓' : 'قيد الدفع',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            color: isPaid ? SahelColors.success : SahelColors.amber,
                          ),
                        ),
                        backgroundColor: isPaid ? SahelColors.successSoft : SahelColors.amberSoft,
                        side: BorderSide.none,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (cancellationAllowed)
            SahelButton.danger(
              label: 'إلغاء الحجز خلال 15 دقيقة (استرداد كامل)',
              onPressed: () {},
            )
          else
            const Text(
              'عذراً، انتهت نافذة الإلغاء المجاني',
              style: TextStyle(color: SahelColors.textMuted, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 12),
          SahelButton.soft(
            label: 'إعادة جدولة الحجز',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
