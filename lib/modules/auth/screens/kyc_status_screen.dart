import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/core/constants/enums.dart';

enum KycStepStatus { pending, uploaded, approved, rejected }

class _KycStep {
  final String title;
  final String subtitle;
  final IconData icon;
  KycStepStatus status;
  XFile? file;

  _KycStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.status = KycStepStatus.pending,
    this.file,
  });
}

class KycStatusScreen extends StatefulWidget {
  const KycStatusScreen({super.key});

  @override
  State<KycStatusScreen> createState() => _KycStatusScreenState();
}

class _KycStatusScreenState extends State<KycStatusScreen> {
  final ImagePicker _picker = ImagePicker();

  final List<_KycStep> _steps = [
    _KycStep(
      title: 'الوجه الأمامي للهوية الشخصية',
      subtitle: 'صورة واضحة للوجه الأمامي لبطاقة الأحوال',
      icon: Icons.badge_outlined,
      status: KycStepStatus.approved,
    ),
    _KycStep(
      title: 'الوجه الخلفي للهوية الشخصية',
      subtitle: 'صورة واضحة للخلف مع عرض العنوان',
      icon: Icons.badge,
      status: KycStepStatus.approved,
    ),
    _KycStep(
      title: 'صورة شخصية تمسك الهوية',
      subtitle: 'صورتي (Selfie) وأنا أمسك الهوية بيدي اليمنى',
      icon: Icons.add_a_photo,
      status: KycStepStatus.pending,
    ),
    _KycStep(
      title: 'رخصة/سجل التجاري',
      subtitle: 'وثيقة مزاولة النشاط أو سجل تجاري',
      icon: Icons.business_center_outlined,
      status: KycStepStatus.pending,
    ),
  ];

  Future<void> _upload(int idx, ImageSource src) async {
    final img = await _picker.pickImage(source: src, imageQuality: 90, maxWidth: 1024);
    if (img != null) {
      setState(() {
        _steps[idx].file = img;
        _steps[idx].status = KycStepStatus.uploaded;
      });
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _showUploadSheet(int idx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(color: SahelColors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 48, height: 5, decoration: BoxDecoration(color: SahelColors.surface3, borderRadius: BorderRadius.circular(3)))),
            const SizedBox(height: 20),
            Text(_steps[idx].title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(_steps[idx].subtitle, style: const TextStyle(fontSize: 12, color: SahelColors.textMuted), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: SahelColors.amberSoft, borderRadius: SahelRadii.smRadius), child: const Icon(Icons.camera_alt, color: SahelColors.amber)),
              title: const Text('الكاميرا', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('التقاط الصورة مباشرة', style: TextStyle(fontSize: 12, color: SahelColors.textMuted)),
              onTap: () => _upload(idx, ImageSource.camera),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: SahelColors.primary50, borderRadius: SahelRadii.smRadius), child: const Icon(Icons.photo_library, color: SahelColors.primary600)),
              title: const Text('المعرض', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('اختيار من الملفات', style: TextStyle(fontSize: 12, color: SahelColors.textMuted)),
              onTap: () => _upload(idx, ImageSource.gallery),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final done = _steps.where((s) => s.status == KycStepStatus.approved).length;
    final progress = done / _steps.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حالة توثيق الحساب (KYC)', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, color: SahelColors.primary600),
            tooltip: 'مساعدة',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: SahelColors.nightGradient, borderRadius: SahelRadii.lgRadius),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), shape: BoxShape.circle),
                      child: const Icon(Icons.verified_user_outlined, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('توثيق الحساب', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text('$done من ${_steps.length} خطوات مكتملة', style: TextStyle(color: SahelColors.primary200, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(SahelColors.primary300),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${(progress * 100).round()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                    const Text('يستغرق المراجعة 24-48 ساعة عمل', style: TextStyle(color: SahelColors.primary200, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: SahelColors.amberSoft.withOpacity(0.14), borderRadius: SahelRadii.pillRadius),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 14, color: SahelColors.primary200),
                      SizedBox(width: 6),
                      Flexible(child: Text('حتى اكتمال التوثيق سيتم تعليق سحب الأرباح', style: TextStyle(color: SahelColors.primary200, fontSize: 11, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('خطوات التوثيق', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...List.generate(_steps.length, (i) {
            final s = _steps[i];
            final isLast = i == _steps.length - 1;
            Color statusColor;
            IconData statusIcon;
            String statusLabel;
            switch (s.status) {
              case KycStepStatus.approved:
                statusColor = SahelColors.success;
                statusIcon = Icons.check_circle;
                statusLabel = 'مصدق عليه ✓';
                break;
              case KycStepStatus.uploaded:
                statusColor = SahelColors.amber;
                statusIcon = Icons.schedule;
                statusLabel = 'قيد المراجعة';
                break;
              case KycStepStatus.rejected:
                statusColor = SahelColors.danger;
                statusIcon = Icons.cancel;
                statusLabel = 'مرفوض - يرجى إعادة الرفع';
                break;
              default:
                statusColor = SahelColors.textMuted;
                statusIcon = Icons.radio_button_unchecked;
                statusLabel = 'بانتظار الرفع';
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: s.status == KycStepStatus.approved
                            ? SahelColors.successSoft
                            : s.status == KycStepStatus.uploaded
                                ? SahelColors.amberSoft
                                : SahelColors.surface2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: s.status == KycStepStatus.approved
                              ? SahelColors.success
                              : s.status == KycStepStatus.uploaded
                                  ? SahelColors.amber
                                  : SahelColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        s.status == KycStepStatus.approved ? Icons.check : s.icon,
                        color: s.status == KycStepStatus.approved
                            ? SahelColors.success
                            : s.status == KycStepStatus.uploaded
                                ? SahelColors.amber
                                : SahelColors.primary600,
                        size: 22,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2.5,
                        height: 56,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: s.status == KycStepStatus.approved ? SahelColors.success : SahelColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                    child: Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: SahelRadii.lgRadius,
                        side: BorderSide(color: s.status == KycStepStatus.rejected ? SahelColors.danger.withOpacity(0.4) : SahelColors.border),
                      ),
                      color: s.status == KycStepStatus.rejected ? SahelColors.dangerSoft.withOpacity(0.3) : SahelColors.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                      const SizedBox(height: 2),
                                      Text(s.subtitle, style: const TextStyle(fontSize: 11, color: SahelColors.textMuted)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: s.status == KycStepStatus.approved
                                        ? SahelColors.successSoft
                                        : s.status == KycStepStatus.uploaded
                                            ? SahelColors.amberSoft
                                            : s.status == KycStepStatus.rejected
                                                ? SahelColors.dangerSoft
                                                : SahelColors.surface3,
                                    borderRadius: SahelRadii.pillRadius,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(statusIcon, size: 12, color: statusColor),
                                      const SizedBox(width: 4),
                                      Text(statusLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: statusColor)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (s.status == KycStepStatus.rejected) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(color: SahelColors.dangerSoft, borderRadius: SahelRadii.smRadius),
                                child: const Row(
                                  children: [
                                    Icon(Icons.feedback_outlined, size: 14, color: SahelColors.danger),
                                    SizedBox(width: 6),
                                    Expanded(child: Text('سبب الرفض: الصورة ضبابية وغير واضحة', style: TextStyle(fontSize: 11, color: SahelColors.danger, fontWeight: FontWeight.w600))),
                                  ],
                                ),
                              ),
                            ],
                            if (s.status != KycStepStatus.approved) ...[
                              const SizedBox(height: 12),
                              if (s.file != null) ...[
                                Row(
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: SahelColors.surface3,
                                        borderRadius: SahelRadii.smRadius,
                                        border: Border.all(color: SahelColors.primary200),
                                      ),
                                      child: const Icon(Icons.image, color: SahelColors.primary600, size: 28),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('وثيقة_مرفقة_01.jpg', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                          SizedBox(height: 2),
                                          Text('الحجم: 2.4 ميجا · جودة عالية', style: TextStyle(fontSize: 11, color: SahelColors.textMuted)),
                                        ],
                                      ),
                                    ),
                                    IconButton(onPressed: () => _showUploadSheet(i), icon: const Icon(Icons.refresh, color: SahelColors.primary600, size: 20), tooltip: 'تعديل'),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                              SahelButton.gradient(
                                label: s.status == KycStepStatus.rejected
                                    ? 'إعادة رفع الوثيقة'
                                    : s.file != null
                                        ? 'تحديث الصورة'
                                        : 'رفع المستند',
                                icon: s.status == KycStepStatus.rejected ? Icons.refresh : Icons.cloud_upload_outlined,
                                height: 42,
                                onPressed: () => _showUploadSheet(i),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: SahelRadii.lgRadius, side: BorderSide(color: SahelColors.primary200)),
            color: SahelColors.primary50,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(color: SahelColors.surface, borderRadius: SahelRadii.smRadius),
                    child: const Icon(Icons.support_agent, color: SahelColors.primary600, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('تحتاج مساعدة؟', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        SizedBox(height: 2),
                        Text('تواصل مع فريق الدعم لحل أي مشكلة في التوثيق', style: TextStyle(fontSize: 11, color: SahelColors.primary700)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('تحدث معنا', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
