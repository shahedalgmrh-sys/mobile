import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';

/// Weekly working hours — `GET /provider/availability` +
/// `POST/DELETE /provider/availability/working-hours`.
///
/// The API stores a single contiguous interval per weekday (unique by
/// provider + day). There is no holidays/exceptions resource, so the screen
/// only manages the recurring weekly schedule.
class WorkingHoursScreen extends ConsumerWidget {
  const WorkingHoursScreen({super.key});

  static const _dayLabels = <int, String>{
    0: 'الأحد',
    1: 'الاثنين',
    2: 'الثلاثاء',
    3: 'الأربعاء',
    4: 'الخميس',
    5: 'الجمعة',
    6: 'السبت',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availability = ref.watch(providerAvailabilityProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ساعات العمل الأسبوعية')),
      body: SafeArea(
        child: availability.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ShimmerCard(height: 60),
              SizedBox(height: 8),
              ShimmerCard(height: 60),
              SizedBox(height: 8),
              ShimmerCard(height: 60),
            ],
          ),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined,
                    size: 52, color: SahelColors.muted),
                const SizedBox(height: 10),
                const Text('تعذر تحميل ساعات العمل',
                    style: TextStyle(
                        color: SahelColors.muted,
                        fontWeight: FontWeight.w700)),
                TextButton.icon(
                  onPressed: () => ref.invalidate(providerAvailabilityProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
          data: (data) {
            final entries = dataList(data['working_hours']);
            final byDay = <int, Map<String, dynamic>>{};
            for (final entry in entries) {
              final day = _dayOf(entry['day_of_week']);
              if (day != null) byDay[day] = entry;
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(providerAvailabilityProvider),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'حدّد فترة العمل لكل يوم. يمكنك إضافة فترة واحدة لكل يوم '
                    'وتعديلها أو حذفها في أي وقت.',
                    style: TextStyle(
                        color: SahelColors.muted,
                        fontSize: 13,
                        height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SahelColors.amber50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ملاحظة: يدعم API الحالي ساعات الأسبوع الثابتة فقط، '
                      'ولا يوفر إجازات أو استثناءات بتاريخ محدد.',
                      style: TextStyle(
                          fontSize: 12,
                          color: SahelColors.amber700,
                          height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final day in _dayLabels.keys) ...[
                    _DayTile(
                      day: day,
                      label: _dayLabels[day]!,
                      entry: byDay[day],
                      onSave: (start, end) => _save(
                        context,
                        ref,
                        day: day,
                        start: start,
                        end: end,
                      ),
                      onDelete: byDay[day] == null
                          ? null
                          : () => _delete(
                                context,
                                ref,
                                str(byDay[day]!['id']),
                                _dayLabels[day]!,
                              ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Accepts integer days (0 = Sunday) or weekday names from the API.
  static int? _dayOf(dynamic raw) {
    if (raw is int) return raw >= 0 && raw <= 6 ? raw : null;
    final parsed = int.tryParse(str(raw));
    if (parsed != null && parsed >= 0 && parsed <= 6) return parsed;
    const names = {
      'sunday': 0,
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5,
      'saturday': 6,
    };
    return names[str(raw).toLowerCase()];
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref, {
    required int day,
    required String start,
    required String end,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(providerRepositoryProvider).storeWorkingHour({
        'day_of_week': day,
        'start_time': start,
        'end_time': end,
      });
      ref.invalidate(providerAvailabilityProvider);
      messenger
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('تم حفظ ساعات العمل ✓')));
    } catch (_) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(
            content: Text('تعذر حفظ ساعات العمل — تحقق من صحة الفترة'),
            backgroundColor: SahelColors.danger));
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String dayLabel,
  ) async {
    if (id.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف ساعات $dayLabel؟'),
        content: const Text('سيصبح هذا اليوم بدون فترة عمل محددة.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حذف',
                  style: TextStyle(color: SahelColors.danger))),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(providerRepositoryProvider).destroyWorkingHour(id);
      ref.invalidate(providerAvailabilityProvider);
      messenger
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('تم حذف الفترة')));
    } catch (_) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(
            content: Text('تعذر حذف الفترة'),
            backgroundColor: SahelColors.danger));
    }
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.day,
    required this.label,
    required this.entry,
    required this.onSave,
    required this.onDelete,
  });

  final int day;
  final String label;
  final Map<String, dynamic>? entry;
  final Future<void> Function(String start, String end) onSave;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final start = _time(entry?['start_time']);
    final end = _time(entry?['end_time']);
    final isActive = entry == null
        ? false
        : toBool(entry!['is_active'], true);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: SahelColors.onPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SahelColors.slate200),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 74,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14)),
          ),
          Expanded(
            child: entry == null
                ? const Text('غير محدد',
                    style: TextStyle(
                        color: SahelColors.muted, fontSize: 13))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${start.isEmpty ? '—' : start}  –  '
                        '${end.isEmpty ? '—' : end}',
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      if (!isActive)
                        const Text('الفترة معطّلة',
                            style: TextStyle(
                                color: SahelColors.muted, fontSize: 11)),
                    ],
                  ),
          ),
          IconButton(
            tooltip: entry == null ? 'إضافة' : 'تعديل',
            onPressed: () => _openEditor(context, start: start, end: end),
            icon: Icon(entry == null ? Icons.add_circle_outline : Icons.edit_outlined,
                color: SahelColors.primary600),
          ),
          if (onDelete != null)
            IconButton(
              tooltip: 'حذف',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline,
                  color: SahelColors.danger),
            ),
        ],
      ),
    );
  }

  static String _time(dynamic raw) {
    final value = str(raw);
    if (value.isEmpty) return '';
    // Backend may return `HH:mm` or `HH:mm:ss`.
    return value.length >= 5 ? value.substring(0, 5) : value;
  }

  Future<void> _openEditor(
    BuildContext context, {
    required String start,
    required String end,
  }) async {
    final startInitial = _parseTime(start) ?? const TimeOfDay(hour: 9, minute: 0);
    final endInitial = _parseTime(end) ?? const TimeOfDay(hour: 17, minute: 0);

    final result = await showDialog<({String start, String end})>(
      context: context,
      builder: (ctx) => _HoursDialog(
        title: label,
        initialStart: startInitial,
        initialEnd: endInitial,
      ),
    );
    if (result == null) return;
    await onSave(result.start, result.end);
  }

  static TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }
}

class _HoursDialog extends StatefulWidget {
  const _HoursDialog({
    required this.title,
    required this.initialStart,
    required this.initialEnd,
  });

  final String title;
  final TimeOfDay initialStart;
  final TimeOfDay initialEnd;

  @override
  State<_HoursDialog> createState() => _HoursDialogState();
}

class _HoursDialogState extends State<_HoursDialog> {
  late TimeOfDay _start = widget.initialStart;
  late TimeOfDay _end = widget.initialEnd;
  String? _error;

  static String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pick({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('ساعات ${widget.title}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(isStart: true),
                  icon: const Icon(Icons.schedule, size: 18),
                  label: Text(_fmt(_start),
                      textDirection: TextDirection.ltr),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('إلى'),
              ),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(isStart: false),
                  icon: const Icon(Icons.schedule, size: 18),
                  label:
                      Text(_fmt(_end), textDirection: TextDirection.ltr),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!,
                style: const TextStyle(
                    color: SahelColors.danger, fontSize: 12)),
          ],
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء')),
        FilledButton(
          onPressed: () {
            if (_fmt(_end).compareTo(_fmt(_start)) <= 0) {
              setState(() => _error = 'يجب أن تكون نهاية الفترة بعد بدايتها');
              return;
            }
            Navigator.pop(
                context,
                (start: _fmt(_start), end: _fmt(_end)));
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
