import 'package:flutter/material.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/core/constants/enums.dart';

class BookingStatusPill extends StatelessWidget {
  final BookingStatus status;

  const BookingStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case BookingStatus.pending:
        bg = SahelColors.amberSoft;
        fg = SahelColors.amber;
        text = 'قيد المراجعة';
        break;
      case BookingStatus.accepted:
        bg = SahelColors.infoSoft;
        fg = SahelColors.primary700;
        text = 'مؤكد';
        break;
      case BookingStatus.inProgress:
        bg = SahelColors.primary50;
        fg = SahelColors.primary700;
        text = 'جاري التنفيذ';
        break;
      case BookingStatus.completed:
        bg = SahelColors.successSoft;
        fg = SahelColors.success;
        text = 'مكتمل';
        break;
      case BookingStatus.rejected:
        bg = SahelColors.dangerSoft;
        fg = SahelColors.danger;
        text = 'مرفوض';
        break;
      case BookingStatus.rescheduled:
        bg = SahelColors.warningSoft;
        fg = SahelColors.warning;
        text = 'معاد جدولته';
        break;
      case BookingStatus.cancelled:
        bg = SahelColors.dangerSoft;
        fg = SahelColors.danger;
        text = 'ملغي';
        break;
      case BookingStatus.refunded:
        bg = SahelColors.violetSoft;
        fg = SahelColors.violet;
        text = 'مردود';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: SahelRadii.pillRadius,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}
