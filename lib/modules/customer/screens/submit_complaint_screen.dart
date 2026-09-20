import 'package:flutter/material.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import '../../../shared/theme/sahel_colors.dart';

class SubmitComplaintScreen extends StatelessWidget {
  final String id;

  const SubmitComplaintScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إبلاغ عن مشكلة')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ما نوع المشكلة؟',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip('تأخر المزود'),
                  _chip('جودة منخفضة'),
                  _chip('سلوك غير لائق'),
                  _chip('اتصال منقطع'),
                  _chip('تكلفة إضافية'),
                  _chip('أخرى'),
                ],
              ),
              const SizedBox(height: 24),
              const TextField(
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'صف المشكلة بالتفصيل...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('إرفاق دليل'),
              ),
              const Spacer(),
              SahelButton(
                label: 'إرسال البلاغ',
                variant: SahelButtonVariant.danger,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: SahelColors.slate100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SahelColors.slate200),
      ),
      child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }
}
