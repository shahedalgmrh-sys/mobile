import 'package:flutter/material.dart';
import '../../../shared/theme/sahel_colors.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التقويم والحجوزات')),
      body: SafeArea(
        child: Column(
          children: [
            CalendarDatePicker(
              initialDate: _selected,
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onDateChanged: (d) => setState(() => _selected = d),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('الحجوزات في هذا اليوم',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 12),
                  _slot('10:00 ص', 'تنظيف عميق', 'أحمد محمد', SahelColors.primary100, SahelColors.primary700),
                  const SizedBox(height: 8),
                  _slot('2:00 م', 'فحص تكييف', 'سارة علي', SahelColors.amber50, SahelColors.amber600),
                  const SizedBox(height: 8),
                  _slot('5:30 م', 'خدمات كهربائية', '---', SahelColors.slate100, SahelColors.muted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slot(String t, String s, String c, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(t, style: TextStyle(fontWeight: FontWeight.w800, color: fg)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s, style: TextStyle(fontWeight: FontWeight.w700, color: fg)),
                if (c.isNotEmpty)
                  Text(c, style: TextStyle(color: fg.withOpacity(0.7), fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
