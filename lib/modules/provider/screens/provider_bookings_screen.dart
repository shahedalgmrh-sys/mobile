import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/shared/widgets/status_pill.dart';
import '../../../models/booking_status.dart';
import '../../../shared/theme/sahel_colors.dart';

class ProviderBookingsScreen extends StatelessWidget {
  const ProviderBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حجوزاتي'),
          bottom: const TabBar(
            tabs: [Tab(text: 'الجديدة'), Tab(text: 'قيد التنفيذ'), Tab(text: 'المكتملة'), Tab(text: 'الملغية')],
            isScrollable: true,
            labelColor: SahelColors.primary700,
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _list(context, [
                ('تنظيف عميق', 'أحمد محمد', '20 سبتمبر · 10:00', BookingStatus.accepted, 'b1'),
                ('فحص تكييف', 'سارة علي', '21 سبتمبر · 2:00', BookingStatus.accepted, 'b2'),
              ]),
              _list(context, [
                ('تركيب رفوف', 'خالد عبدالله', 'الآن', BookingStatus.inProgress, 'b3'),
              ]),
              _list(context, [
                ('تنظيف منزلي', 'محمد صالح', '15 سبتمبر', BookingStatus.completed, 'b4'),
              ]),
              _list(context, [
                ('تصليح ثلاجة', 'نورا حسن', '10 سبتمبر', BookingStatus.cancelled, 'b5'),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _list(BuildContext context, List<(String, String, String, BookingStatus, String)> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final it = items[i];
        return GestureDetector(
          onTap: () => context.push('/p/bookings/${it.$5}'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: SahelColors.slate200),
            ),
            child: Row(
              children: [
                Container(width: 4, height: 52, decoration: BoxDecoration(
                    color: it.$4 == BookingStatus.inProgress
                        ? SahelColors.primary500
                        : it.$4 == BookingStatus.completed
                            ? SahelColors.green600
                            : it.$4 == BookingStatus.cancelled
                                ? SahelColors.red600
                                : SahelColors.amber500,
                    borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(it.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('${it.$2} · ${it.$3}', style: const TextStyle(color: SahelColors.muted, fontSize: 12)),
                    ],
                  ),
                ),
                BookingStatusPill(status: it.$4),
              ],
            ),
          ),
        );
      },
    );
  }
}
