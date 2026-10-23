import 'package:flutter/material.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/core/constants/enums.dart';

enum StatusTone { teal, amber, red, violet, green, slate, sky }

class BookingStatusPill extends StatelessWidget {
  final BookingStatus status;

  const BookingStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: config.$1,
        borderRadius: SahelRadii.pillRadius,
      ),
      child: Text(
        config.$3,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: config.$2,
        ),
      ),
    );
  }

  (Color, Color, String) _statusConfig(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:
        return (SahelColors.amberSoft, SahelColors.amber700, 'قيد الانتظار');
      case BookingStatus.accepted:
        return (SahelColors.infoSoft, SahelColors.info, 'تم القبول');
      case BookingStatus.inProgress:
        return (SahelColors.primary100, SahelColors.primary600, 'قيد التنفيذ');
      case BookingStatus.paid:
        return (SahelColors.successSoft, SahelColors.success, 'مدفوع');
      case BookingStatus.completed:
        return (SahelColors.successSoft, SahelColors.success, 'مكتمل');
      case BookingStatus.rejected:
        return (SahelColors.surfaceInset, SahelColors.textMuted, 'مرفوض');
      case BookingStatus.cancelled:
        return (SahelColors.dangerSoft, SahelColors.danger, 'ملغي');
      case BookingStatus.rescheduled:
        return (SahelColors.violetSoft, SahelColors.violet, 'إعادة جدولة');
      case BookingStatus.refunded:
        return (SahelColors.amberSoft, SahelColors.amber800, 'تم الاسترداد');
    }
  }
}

class StatusPill extends StatelessWidget {
  final String text;
  final StatusTone tone;

  const StatusPill({
    super.key,
    required this.text,
    this.tone = StatusTone.teal,
  });

  factory StatusPill.teal({required String text}) =>
      StatusPill(text: text, tone: StatusTone.teal);

  factory StatusPill.verifiedTeal({required String text}) =>
      StatusPill(text: text, tone: StatusTone.teal);

  factory StatusPill.slate({required String text}) =>
      StatusPill(text: text, tone: StatusTone.slate);

  @override
  Widget build(BuildContext context) {
    final config = _toneConfig(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.$1,
        borderRadius: SahelRadii.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tone == StatusTone.teal) ...[
            const Icon(
              Icons.check_circle,
              size: 12,
              color: SahelColors.primary600,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: config.$2,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _toneConfig(StatusTone t) {
    switch (t) {
      case StatusTone.teal:
        return (SahelColors.primary100, SahelColors.primary600);
      case StatusTone.amber:
        return (SahelColors.amberSoft, SahelColors.amber700);
      case StatusTone.red:
        return (SahelColors.dangerSoft, SahelColors.danger);
      case StatusTone.violet:
        return (SahelColors.violetSoft, SahelColors.violet);
      case StatusTone.green:
        return (SahelColors.successSoft, SahelColors.success);
      case StatusTone.slate:
        return (SahelColors.surfaceInset, SahelColors.textMuted);
      case StatusTone.sky:
        return (SahelColors.infoSoft, SahelColors.info);
    }
  }
}
