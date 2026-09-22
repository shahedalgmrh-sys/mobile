import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import '../../../shared/widgets/booking_status_pill.dart';
import '../../../shared/widgets/booking_status_stepper.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/core/constants/enums.dart';

class BookingManagementDetails extends StatefulWidget {
  const BookingManagementDetails({super.key});

  @override
  State<BookingManagementDetails> createState() => _BookingManagementDetailsState();
}

class _BookingManagementDetailsState extends State<BookingManagementDetails> {
  BookingStatus status = BookingStatus.accepted;
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _proofImages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تفاصيل الحجز #BK-20260919',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: BookingStatusPill(status: status),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BookingStatusStepper(status: status),
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
                  const Text('بيانات العميل', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(radius: 24, backgroundColor: SahelColors.primary100, child: const Icon(Icons.person, color: SahelColors.primary700, size: 26)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('آمال أحمد عبدالله', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            SizedBox(height: 2),
                            Text('+967 777 123 456', style: TextStyle(fontSize: 12, color: SahelColors.textMuted)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final tel = Uri.parse('tel:+967777123456');
                          if (await canLaunchUrl(tel)) await launchUrl(tel);
                        },
                        icon: const Icon(Icons.call, color: SahelColors.primary600),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.chat, color: SahelColors.primary600),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  Row(
                    children: [
                      const Text('الخدمة المطلوبة', style: TextStyle(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: SahelColors.primary50, borderRadius: SahelRadii.pillRadius),
                        child: const Text('تنظيف شقق - 3 غرف', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: SahelColors.primary700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('الموعد', style: TextStyle(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text('السبت 20 سبتمبر · 10:00 صباحاً', style: TextStyle(fontSize: 13, color: SahelColors.primary700, fontWeight: FontWeight.w700)),
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
                          'شارع الجزائر، حي الحصبة، صنعاء، اليمن\nعمارة رقم 15، شقة رقم 3',
                          style: TextStyle(fontSize: 13, height: 1.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('القيمة المالية', style: TextStyle(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      const Text('1,000 ر.س', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: SahelColors.primary700)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (status == BookingStatus.inProgress) ...[
            Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: SahelRadii.lgRadius, side: const BorderSide(color: SahelColors.border)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('إرفاق صور إثبات إنجاز العمل', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    const Text('صور قبل وبعد انتهاء الخدمة (اختياري ولكن مفضّل)', style: TextStyle(fontSize: 12, color: SahelColors.textMuted)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ...List.generate(_proofImages.length, (i) {
                          return Stack(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  color: SahelColors.surface3,
                                  borderRadius: SahelRadii.smRadius,
                                  border: Border.all(color: SahelColors.border),
                                ),
                                child: const Icon(Icons.image, size: 36, color: SahelColors.textMuted),
                              ),
                              Positioned(
                                top: 4,
                                left: 4,
                                child: InkWell(
                                  onTap: () => setState(() => _proofImages.removeAt(i)),
                                  borderRadius: BorderRadius.circular(999),
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(color: SahelColors.danger, shape: BoxShape.circle),
                                    child: const Icon(Icons.close, color: Colors.white, size: 14),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        InkWell(
                          onTap: () async {
                            final images = await _picker.pickMultiImage(imageQuality: 80);
                            if (images.isNotEmpty) {
                              setState(() => _proofImages.addAll(images));
                            }
                          },
                          borderRadius: SahelRadii.smRadius,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: SahelColors.primary50,
                              borderRadius: SahelRadii.smRadius,
                              border: Border.all(color: SahelColors.primary200, style: BorderStyle.solid),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, size: 28, color: SahelColors.primary600),
                                SizedBox(height: 3),
                                Text('إضافة', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: SahelColors.primary700)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          _buildActionButtons(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    switch (status) {
      case BookingStatus.pending:
        return Row(
          children: [
            Expanded(
              child: SahelButton.gradient(
                label: 'قبول الحجز',
                onPressed: () => setState(() => status = BookingStatus.accepted),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SahelButton.danger(
                label: 'رفض مع سبب',
                onPressed: () => _showRejectDialog(context),
              ),
            ),
          ],
        );
      case BookingStatus.accepted:
        return Row(
          children: [
            Expanded(
              child: SahelButton.gradient(
                label: 'بدء الخدمة الآن',
                onPressed: () => setState(() => status = BookingStatus.inProgress),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 50,
              height: 48,
              child: SahelButton.soft(
                label: '',
                icon: Icons.call,
                onPressed: () async {
                  final tel = Uri.parse('tel:+967777123456');
                  if (await canLaunchUrl(tel)) await launchUrl(tel);
                },
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 50,
              height: 48,
              child: SahelButton.soft(
                label: '',
                icon: Icons.chat,
                onPressed: () {},
              ),
            ),
          ],
        );
      case BookingStatus.inProgress:
        return Row(
          children: [
            SizedBox(
              width: 50,
              height: 48,
              child: SahelButton.soft(
                label: '',
                icon: Icons.add_photo_alternate,
                onPressed: () async {
                  final images = await _picker.pickMultiImage(imageQuality: 80);
                  if (images.isNotEmpty) setState(() => _proofImages.addAll(images));
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SahelButton(
                label: 'إكمال الخدمة',
                variant: SahelButtonVariant.gradient,
                bgColor: SahelColors.success,
                onPressed: () => setState(() => status = BookingStatus.completed),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showRejectDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: SahelRadii.lgRadius),
        title: const Row(
          children: [
            Icon(Icons.cancel, color: SahelColors.danger),
            SizedBox(width: 8),
            Text('رفض الحجز', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('يرجى ذكر سبب الرفض للعميل:', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'مثال: أنا مشغول في هذا الموعد...',
                filled: true,
                fillColor: SahelColors.surface2,
                border: OutlineInputBorder(borderRadius: SahelRadii.mdRadius, borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: const [
                _QuickChip(label: 'مشغول'),
                _QuickChip(label: 'الموعد غير مناسب'),
                _QuickChip(label: 'خدمة غير متوفرة'),
                _QuickChip(label: 'بعيد جداً عن المنطقة'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء', style: TextStyle(color: SahelColors.textMuted, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => status = BookingStatus.cancelled);
            },
            style: ElevatedButton.styleFrom(backgroundColor: SahelColors.danger, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: SahelRadii.pillRadius)),
            child: const Text('تأكيد الرفض', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  const _QuickChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: SahelColors.surface2,
        borderRadius: SahelRadii.pillRadius,
        border: Border.all(color: SahelColors.border),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: SahelColors.textMuted)),
    );
  }
}
