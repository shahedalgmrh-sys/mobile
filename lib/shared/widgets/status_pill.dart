import 'package:flutter/material.dart';
import 'package:saber_flutter/models/booking_status.dart';

enum StatusTone {
  teal,
  amber,
  red,
  violet,
  green,
  slate,
  sky,
}

class BookingStatusPill extends StatelessWidget {
  final BookingStatus status;

  const BookingStatusPill({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: config.$1,
        borderRadius: BorderRadius.circular(999),
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
        return (const Color(0xFFFFF7E6), const Color(0xFFB45309), 'قيد الانتظار');
      case BookingStatus.accepted:
        return (const Color(0xFFEFF6FF), const Color(0xFF0369A1), 'تم القبول');
      case BookingStatus.inProgress:
        return (const Color(0xFFCCFBF1), const Color(0xFF0F766E), 'قيد التنفيذ');
      case BookingStatus.paid:
        return (const Color(0xFFECFDF5), const Color(0xFF059669), 'مدفوع');
      case BookingStatus.completed:
        return (const Color(0xFFECFDF5), const Color(0xFF059669), 'مكتمل');
      case BookingStatus.rejected:
        return (const Color(0xFFF1F5F9), const Color(0xFF64748B), 'مرفوض');
      case BookingStatus.cancelled:
        return (const Color(0xFFFEF2F2), const Color(0xFFDC2626), 'ملغي');
      case BookingStatus.rescheduled:
        return (const Color(0xFFF3F0FF), const Color(0xFF6D28D9), 'إعادة جدولة');
      case BookingStatus.refunded:
        return (const Color(0xFFFEF3C7), const Color(0xFF92400E), 'تم الاسترداد');
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

  factory StatusPill.teal({required String text}) => StatusPill(
        text: text,
        tone: StatusTone.teal,
      );

  factory StatusPill.verifiedTeal({required String text}) => StatusPill(
        text: text,
        tone: StatusTone.teal,
      );

  factory StatusPill.slate({required String text}) => StatusPill(
        text: text,
        tone: StatusTone.slate,
      );

  @override
  Widget build(BuildContext context) {
    final config = _toneConfig(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.$1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tone == StatusTone.teal) ...[
            const Icon(Icons.check_circle, size: 12, color: Color(0xFF0F766E)),
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
        return (const Color(0xFFCCFBF1), const Color(0xFF0F766E));
      case StatusTone.amber:
        return (const Color(0xFFFFF7E6), const Color(0xFFB45309));
      case StatusTone.red:
        return (const Color(0xFFFEF2F2), const Color(0xFFDC2626));
      case StatusTone.violet:
        return (const Color(0xFFF3F0FF), const Color(0xFF6D28D9));
      case StatusTone.green:
        return (const Color(0xFFECFDF5), const Color(0xFF059669));
      case StatusTone.slate:
        return (const Color(0xFFF1F5F9), const Color(0xFF64748B));
      case StatusTone.sky:
        return (const Color(0xFFEFF6FF), const Color(0xFF0369A1));
    }
  }
}
