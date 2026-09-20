import 'package:flutter/material.dart';
import 'package:saber_flutter/core/constants/enums.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'booking_status_pill.dart';

class BookingStatusStepper extends StatelessWidget {
  final BookingStatus status;

  const BookingStatusStepper({super.key, required this.status});

  int get _currentStep {
    switch (status) {
      case BookingStatus.pending:
        return 0;
      case BookingStatus.accepted:
        return 1;
      case BookingStatus.inProgress:
        return 3;
      case BookingStatus.completed:
        return 4;
      case BookingStatus.rescheduled:
        return 1;
      case BookingStatus.rejected:
      case BookingStatus.cancelled:
      case BookingStatus.refunded:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    const steps = [
      (icon: Icons.receipt_long, title: 'تم استلام الطلب'),
      (icon: Icons.check_circle, title: 'تأكيد المزوّد'),
      (icon: Icons.directions_car, title: 'المزوّد في الطريق'),
      (icon: Icons.build, title: 'جاري التنفيذ'),
      (icon: Icons.celebration, title: 'اكتمل الخدمة'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length, (i) {
              final isDone = i < _currentStep;
              final isCurrent = i == _currentStep;
              final active = isDone || isCurrent;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: i == 0
                              ? Colors.transparent
                              : (isDone ? SahelColors.primary500 : SahelColors.border),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active ? SahelColors.primary500 : SahelColors.surface3,
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: SahelColors.primary500.withOpacity(0.4),
                                      blurRadius: 10,
                                      spreadRadius: 3,
                                    ),
                                  ]
                                : null,
                            border: Border.all(
                              color: active ? SahelColors.primary300 : SahelColors.border,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            isDone ? Icons.check : steps[i].icon,
                            size: 18,
                            color: active ? Colors.white : SahelColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          steps[i].title,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: active ? SahelColors.primary700 : SahelColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: i == steps.length - 1
                              ? Colors.transparent
                              : (i < _currentStep ? SahelColors.primary500 : SahelColors.border),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
