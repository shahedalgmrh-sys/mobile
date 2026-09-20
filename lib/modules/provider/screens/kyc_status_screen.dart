import 'package:flutter/material.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/shared/widgets/status_pill.dart';
import '../../../shared/theme/sahel_colors.dart';

class KycStatusScreen extends StatelessWidget {
  const KycStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التحقق من الهوية (KYC)')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: SahelColors.primary50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: SahelColors.primary100),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: SahelColors.primary100,
                    child: Icon(Icons.verified_user, color: SahelColors.primary700, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الحالة الحالية',
                            style: TextStyle(color: SahelColors.muted, fontSize: 12)),
                        SizedBox(height: 4),
                        StatusPill.verifiedTeal(text: 'قيد المراجعة'),
                        SizedBox(height: 6),
                        Text('سيتم مراجعة وثائقك خلال 24-48 ساعة عمل.',
                            style: TextStyle(color: SahelColors.primary700, fontSize: 12, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('الوثائق المطلوبة',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            _doc('بطاقة الهوية الوطنية', true),
            const SizedBox(height: 10),
            _doc('الإقامة / تصريح العمل', true),
            const SizedBox(height: 10),
            _doc('شهادات التدريب المهني', false),
            const SizedBox(height: 10),
            _doc('صورة شخصية حديثة', true),
            const SizedBox(height: 28),
            SahelButton.soft(
                label: 'إعادة رفع الوثائق', onTap: () {}, prefixIcon: Icons.cloud_upload_outlined),
            const SizedBox(height: 10),
            SahelButton(label: 'حفظ ومتابعة', variant: SahelButtonVariant.gradient, onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _doc(String t, bool done) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SahelColors.slate200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: done ? SahelColors.green600.withOpacity(0.12) : SahelColors.slate100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              done ? Icons.check_circle : Icons.upload_file_outlined,
              color: done ? SahelColors.green600 : SahelColors.muted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Text(done ? 'مرفوع' : 'مطلوب',
              style: TextStyle(
                  color: done ? SahelColors.green600 : SahelColors.red600,
                  fontWeight: FontWeight.w700,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
