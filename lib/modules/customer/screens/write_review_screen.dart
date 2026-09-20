import 'package:flutter/material.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import '../../../shared/theme/sahel_colors.dart';

class WriteReviewScreen extends StatefulWidget {
  final String id;

  const WriteReviewScreen({
    super.key,
    required this.id,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  double _overall = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('كتابة تقييم')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('كيف كانت تجربتك؟',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => _overall = (i + 1).toDouble()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        i < _overall ? Icons.star : Icons.star_outline,
                        size: 40,
                        color: SahelColors.amber500,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              const TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'أخبرنا أكثر عن تجربتك مع مزود الخدمة...',
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('إضافة صور'),
              ),
              const Spacer(),
              SahelButton(
                label: 'نشر التقييم',
                variant: SahelButtonVariant.gradient,
                onPressed: _overall >= 1 ? () {} : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
