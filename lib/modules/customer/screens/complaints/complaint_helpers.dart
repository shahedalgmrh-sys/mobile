import 'package:flutter/material.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/core/utils/format.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';

/// Status values stored by the API: open, in_progress, resolved, closed.
String complaintStatusLabel(dynamic raw) {
  final s = str(raw, 'open').toLowerCase();
  if (s == 'closed') return 'مغلقة';
  if (s == 'resolved') return 'تم الحل';
  if (s == 'in_progress' || s.contains('progress')) return 'قيد المعالجة';
  if (s == 'open' || s == 'new') return 'مفتوحة';
  return s;
}

Color complaintStatusColor(String raw) {
  switch (raw.toLowerCase()) {
    case 'closed':
      return SahelColors.textMuted;
    case 'resolved':
      return SahelColors.success;
    case 'in_progress':
      return SahelColors.amber500;
    case 'open':
    case 'new':
      return SahelColors.info;
    default:
      return SahelColors.textMuted;
  }
}

/// Priority values accepted by the API: low, medium, high, urgent.
String complaintPriorityLabel(dynamic raw) {
  switch (str(raw, 'medium').toLowerCase()) {
    case 'low':
      return 'منخفضة';
    case 'high':
      return 'عالية';
    case 'urgent':
      return 'عاجلة';
    case 'medium':
      return 'متوسطة';
    default:
      return str(raw);
  }
}

Color complaintPriorityColor(String raw) {
  switch (raw.toLowerCase()) {
    case 'urgent':
      return SahelColors.danger;
    case 'high':
      return SahelColors.amber700;
    case 'medium':
      return SahelColors.info;
    default:
      return SahelColors.textMuted;
  }
}

String complaintDate(dynamic raw) => formatDateTime(raw);

/// `messages` are returned newest-first by the API; the UI shows them oldest-first.
List<Map<String, dynamic>> complaintMessages(Map<String, dynamic> complaint) {
  final list = asList(complaint['messages']).map(asMap).toList();
  return list.reversed.toList();
}

/// Latest support reply, for the list preview.
Map<String, dynamic>? complaintLatestMessage(Map<String, dynamic> complaint) {
  final list = asList(complaint['messages']).map(asMap).toList();
  return list.isEmpty ? null : list.first;
}
