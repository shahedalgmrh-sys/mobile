import 'package:intl/intl.dart';

import '../../data/repositories/parsers.dart';

final _moneyFormat = NumberFormat('#,##0.00', 'en');

/// Padding for the numeric date parts. Dates are formatted manually so the
/// widget layer never depends on `initializeDateFormatting` having run (the
/// app initializes it through the localization delegates, unit tests may not).
String _two(int value) => value.toString().padLeft(2, '0');

/// Formats a numeric amount (wallet balance, transaction amount, ...),
/// returning an em dash when the API omitted the value.
String formatMoney(dynamic value) {
  final amount = toDoubleOrNull(value);
  if (amount == null) return '—';
  return _moneyFormat.format(amount);
}

/// Formats an ISO timestamp from the API; empty string when unparseable.
String formatDateTime(dynamic value) {
  final parsed = toDate(value);
  if (parsed == null) return '';
  final local = parsed.toLocal();
  return '${local.year}/${_two(local.month)}/${_two(local.day)}'
      ' – ${_two(local.hour)}:${_two(local.minute)}';
}

/// Formats a date (without the time); empty string when unparseable.
String formatDate(dynamic value) {
  final parsed = toDate(value);
  if (parsed == null) return '';
  final local = parsed.toLocal();
  return '${local.year}/${_two(local.month)}/${_two(local.day)}';
}
