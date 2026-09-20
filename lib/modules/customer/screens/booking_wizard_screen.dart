import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import '../../../shared/theme/sahel_colors.dart';

class BookingWizardScreen extends StatefulWidget {
  const BookingWizardScreen({super.key});

  @override
  State<BookingWizardScreen> createState() => _BookingWizardScreenState();
}

class _BookingWizardScreenState extends State<BookingWizardScreen> {
  int _step = 0;

  static const _titles = ['اختر الخدمة', 'اختر التاريخ والوقت', 'اختر المزود', 'الملخص والدفع'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حجز جديد')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  for (int i = 0; i < 4; i++) ...[
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: i <= _step ? SahelColors.primary500 : SahelColors.slate200,
                      child: Text('${i + 1}',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: i <= _step ? Colors.white : SahelColors.muted)),
                    ),
                    if (i < 3)
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 3,
                          decoration: BoxDecoration(
                              color: i < _step ? SahelColors.primary400 : SahelColors.slate200,
                              borderRadius: BorderRadius.circular(999)),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _titles[_step],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'خطوة ${_step + 1} من 4 - ${_titles[_step]}',
                    style: const TextStyle(color: SahelColors.muted, fontSize: 15),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                child: Row(
                  children: [
                    if (_step > 0)
                      Expanded(
                        child: SahelButton.soft(
                          label: 'السابق',
                          onTap: () => setState(() => _step--),
                        ),
                      ),
                    if (_step > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: SahelButton(
                        label: _step == 3 ? 'تأكيد الدفع' : 'التالي',
                        variant: SahelButtonVariant.gradient,
                        onPressed: () {
                          if (_step < 3) {
                            setState(() => _step++);
                          } else {
                            context.go('/bookings/new_confirmed');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
