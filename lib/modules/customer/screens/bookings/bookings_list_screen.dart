import 'package:flutter/material.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/booking_status_pill.dart';
import 'booking_details_screen.dart';
import 'package:saber_flutter/core/constants/enums.dart';

class BookingsListScreen extends StatelessWidget {
  const BookingsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      initialIndex: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'حجوزاتي',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: SahelColors.primary700,
            unselectedLabelColor: SahelColors.textMuted,
            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            indicatorColor: SahelColors.primary700,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'الجميع'),
              Tab(text: 'القادمة'),
              Tab(text: 'جارية'),
              Tab(text: 'مكتملة'),
              Tab(text: 'ملغية'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabList([
              BookingStatus.inProgress,
              BookingStatus.accepted,
              BookingStatus.completed,
              BookingStatus.pending,
              BookingStatus.cancelled,
              BookingStatus.accepted,
              BookingStatus.completed,
              BookingStatus.accepted,
            ]),
            _buildTabList([
              BookingStatus.accepted,
              BookingStatus.accepted,
              BookingStatus.pending,
              BookingStatus.accepted,
              BookingStatus.pending,
              BookingStatus.accepted,
              BookingStatus.accepted,
              BookingStatus.pending,
            ]),
            _buildTabList([
              BookingStatus.inProgress,
              BookingStatus.accepted,
              BookingStatus.inProgress,
              BookingStatus.accepted,
              BookingStatus.inProgress,
              BookingStatus.accepted,
              BookingStatus.inProgress,
              BookingStatus.accepted,
            ]),
            _buildTabList([
              BookingStatus.completed,
              BookingStatus.completed,
              BookingStatus.completed,
              BookingStatus.completed,
              BookingStatus.completed,
              BookingStatus.completed,
              BookingStatus.completed,
              BookingStatus.completed,
            ]),
            _buildTabList([
              BookingStatus.cancelled,
              BookingStatus.cancelled,
              BookingStatus.cancelled,
              BookingStatus.cancelled,
              BookingStatus.cancelled,
              BookingStatus.cancelled,
              BookingStatus.cancelled,
              BookingStatus.cancelled,
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildTabList(List<BookingStatus> statuses) {
    final serviceNames = const [
      'تنظيف شقق',
      'صيانة مكيفات',
      'سباكة منزلية',
      'كهرباء عامة',
      'دهان جدران',
      'تنظيف منازل',
      'صيانة ثلاجة',
      'نجارة أثاث',
    ];
    final icons = const [
      Icons.cleaning_services,
      Icons.air,
      Icons.plumbing,
      Icons.electrical_services,
      Icons.format_paint,
      Icons.home,
      Icons.kitchen,
      Icons.carpenter,
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (ctx, i) {
        final bookingNumber = 20260000 + (i * 137) + 919;
        final day = 15 + i;
        final total = 150 + (i * 50);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: SahelColors.surface,
            borderRadius: SahelRadii.mdRadius,
            elevation: 0,
            child: InkWell(
              onTap: () {
                Navigator.of(ctx).push(
                  MaterialPageRoute(builder: (_) => const BookingDetailsScreen()),
                );
              },
              borderRadius: SahelRadii.mdRadius,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: SahelRadii.mdRadius,
                  border: Border.all(color: SahelColors.border),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: SahelColors.primaryGradient,
                        borderRadius: SahelRadii.smRadius,
                      ),
                      child: Icon(icons[i], color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                serviceNames[i],
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              const Spacer(),
                              BookingStatusPill(status: statuses[i]),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'BK-$bookingNumber · ${day.toString().padLeft(2, '0')}/09/2026 · ${total.toStringAsFixed(0)} ر.س',
                            style: const TextStyle(
                              fontSize: 12,
                              color: SahelColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: SahelColors.primary600),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
