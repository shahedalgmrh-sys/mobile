import 'package:flutter/material.dart';
import 'package:saber_flutter/models/booking_status.dart';
import '../theme/sahel_colors.dart';

class BookingStatusStepper extends StatelessWidget {
  final BookingStatus status;

  const BookingStatusStepper({
    super.key,
    required this.status,
  });

  static const List<String> _labels = [
    'قيد الانتظار',
    'تم القبول',
    'قيد التنفيذ',
    'مدفوع',
    'مكتمل',
  ];

  int get currentStage {
    switch (status) {
      case BookingStatus.pending:
        return 0;
      case BookingStatus.accepted:
        return 1;
      case BookingStatus.inProgress:
        return 2;
      case BookingStatus.paid:
        return 3;
      case BookingStatus.completed:
      case BookingStatus.cancelled:
      case BookingStatus.refunded:
      case BookingStatus.rejected:
      case BookingStatus.rescheduled:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (int i = 0; i < 5; i++) ...[
              _buildCircle(i),
              if (i < 4) _buildLine(i < currentStage),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (int i = 0; i < 5; i++) ...[
              Expanded(
                child: Text(
                  _labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: i <= currentStage ? FontWeight.w700 : FontWeight.w500,
                    color: i <= currentStage ? SahelColors.primary700 : SahelColors.muted,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCircle(int index) {
    final isFilled = index <= currentStage;
    return CircleAvatar(
      radius: 14,
      backgroundColor: isFilled ? SahelColors.primary500 : Colors.white,
      child: isFilled
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: SahelColors.slate300, width: 2),
                ),
              ),
            ),
    );
  }

  Widget _buildLine(bool filled) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        height: 3,
        decoration: BoxDecoration(
          color: filled ? SahelColors.primary400 : SahelColors.slate200,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
