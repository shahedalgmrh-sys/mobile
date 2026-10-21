import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import '../../../shared/theme/sahel_colors.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selected = DateTime.now();

  String get _dateParam =>
      '${_selected.year.toString().padLeft(4, '0')}-'
      '${_selected.month.toString().padLeft(2, '0')}-'
      '${_selected.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final bookings =
        ref.watch(providerBookingsProvider((status: null, date: _dateParam)));

    return Scaffold(
      appBar: AppBar(title: const Text('التقويم والحجوزات')),
      body: SafeArea(
        child: Column(
          children: [
            CalendarDatePicker(
              initialDate: _selected,
              firstDate: DateTime.now().subtract(const Duration(days: 90)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onDateChanged: (d) => setState(() => _selected = d),
            ),
            const Divider(height: 1),
            Expanded(
              child: bookings.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: TextButton.icon(
                    onPressed: () => ref.invalidate(
                        providerBookingsProvider(
                            (status: null, date: _dateParam))),
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ),
                data: (items) => RefreshIndicator(
                  onRefresh: () async => ref.invalidate(
                      providerBookingsProvider(
                          (status: null, date: _dateParam))),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text('الحجوزات في هذا اليوم',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 12),
                      if (items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text('لا توجد حجوزات في هذا اليوم',
                                style:
                                    TextStyle(color: SahelColors.muted)),
                          ),
                        )
                      else
                        for (final b in items) ...[
                          _slot(b),
                          const SizedBox(height: 8),
                        ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slot(Map<String, dynamic> b) {
    final service = asMap(b['service']);
    final customer = asMap(b['customer'] ?? b['customer_profile']);
    final customerUser = asMap(customer['user']);
    final status = str(b['status']);
    final (bg, fg) = switch (status) {
      'pending' => (SahelColors.amber50, SahelColors.amber600),
      'accepted' || 'in_progress' || 'paid' => (
          SahelColors.primary100,
          SahelColors.primary700
        ),
      'completed' => (SahelColors.slate100, SahelColors.muted),
      _ => (SahelColors.slate100, SahelColors.muted),
    };
    final time = str(b['scheduled_time'] ?? b['time'] ?? b['start_time']);
    final id = str(b['id']);

    return InkWell(
      onTap: id.isNotEmpty ? () => context.push('/p/bookings/$id') : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(time.isEmpty ? '—' : time,
                  style: TextStyle(fontWeight: FontWeight.w800, color: fg)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(str(service['name'] ?? service['title'], 'خدمة'),
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: fg)),
                  Text(str(customerUser['name'] ?? customer['name']),
                      style: TextStyle(
                          color: fg.withValues(alpha: 0.7), fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
