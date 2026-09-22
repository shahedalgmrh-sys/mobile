/// Defensive JSON parsing helpers for Laravel snake_case payloads.
library;

Map<String, dynamic> asMap(dynamic v) =>
    v is Map<String, dynamic> ? v : (v is Map ? Map<String, dynamic>.from(v) : {});

List<dynamic> asList(dynamic v) => v is List ? v : const [];

List<Map<String, dynamic>> asMapList(dynamic v) =>
    asList(v).map(asMap).toList();

String str(dynamic v, [String fallback = '']) => v?.toString() ?? fallback;

String? strOrNull(dynamic v) => v == null ? null : v.toString();

int toInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? fallback;
}

int? toIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

double toDouble(dynamic v, [double fallback = 0]) {
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? fallback;
}

double? toDoubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

bool toBool(dynamic v, [bool fallback = false]) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v?.toString().toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return fallback;
}

DateTime? toDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  return DateTime.tryParse(v.toString());
}

/// Unwraps common Laravel pagination/resource wrappers to a plain list.
List<Map<String, dynamic>> dataList(dynamic data) {
  if (data is List) return asMapList(data);
  final m = asMap(data);
  if (m['data'] is List) return asMapList(m['data']);
  if (m['items'] is List) return asMapList(m['items']);
  if (m['results'] is List) return asMapList(m['results']);
  return asMapList(data);
}
