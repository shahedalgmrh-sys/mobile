import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/core/constants/enums.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/booking_status_pill.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

class BookingsListScreen extends ConsumerWidget {
  const BookingsListScreen({super.key});

  static const _tabs = [
    (label: 'الجميع', status: null),
    (label: 'القادمة', status: 'upcoming'),
    (label: 'جارية', status: 'in_progress'),
    (label: 'مكتملة', status: 'completed'),
    (label: 'ملغية', status: 'cancelled'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: _tabs.length,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'حجوزاتي',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            labelColor: SahelColors.primary700,
            unselectedLabelColor: SahelColors.textMuted,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            indicatorColor: SahelColors.primary700,
            indicatorWeight: 3,
            tabs: [for (final t in _tabs) Tab(text: t.label)],
          ),
        ),
        body: TabBarView(
          children: [
            for (final t in _tabs) _BookingsTab(status: t.status),
          ],
        ),
      ),
    );
  }
}

class _BookingsTab extends ConsumerWidget {
  final String? status;
  const _BookingsTab({this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(customerBookingsProvider(status));

    return bookings.when(
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: ShimmerCard(height: 84),
        ),
      ),
      error: (e, _) => _ErrorState(
        onRetry: () => ref.invalidate(customerBookingsProvider(status)),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const _EmptyState();
        }
        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(customerBookingsProvider(status)),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (ctx, i) => _BookingCard(booking: items[i]),
          ),
        );
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  const _BookingCard({required this.booking});

  BookingStatus _status(String s) => switch (s) {
        'pending' => BookingStatus.pending,
        'accepted' => BookingStatus.accepted,
        'in_progress' => BookingStatus.inProgress,
        'completed' => BookingStatus.completed,
        'cancelled' => BookingStatus.cancelled,
        _ => BookingStatus.pending,
      };

  @override
  Widget build(BuildContext context) {
    final service = asMap(booking['service']);
    final number = str(booking['booking_number'] ?? booking['id']);
    final date = str(booking['booking_date'] ?? booking['scheduled_at']);
    final price = str(booking['formatted_total'] ??
        booking['display_price'] ??
        booking['total']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: SahelColors.surface,
        borderRadius: SahelRadii.mdRadius,
        elevation: 0,
        child: InkWell(
          onTap: () => context.push('/bookings/${booking['id']}'),
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
                  child: const Icon(Icons.home_repair_service,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              str(service['name'], 'خدمة'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                          ),
                          BookingStatusPill(
                              status: _status(str(booking['status']))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        [
                          if (number.isNotEmpty) 'BK-$number',
                          if (date.isNotEmpty) date,
                          if (price.isNotEmpty) price,
                        ].join(' · '),
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
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy_outlined,
              size: 56, color: SahelColors.textMuted),
          SizedBox(height: 12),
          Text(
            'لا توجد حجوزات هنا بعد',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: SahelColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined,
              size: 56, color: SahelColors.textMuted),
          const SizedBox(height: 12),
          const Text(
            'تعذر تحميل الحجوزات',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: SahelColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
