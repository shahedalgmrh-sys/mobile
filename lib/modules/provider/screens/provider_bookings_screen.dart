import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';
import 'package:saber_flutter/shared/widgets/status_pill.dart';
import '../../../models/booking_status.dart';
import '../../../shared/theme/sahel_colors.dart';

class ProviderBookingsScreen extends ConsumerWidget {
  const ProviderBookingsScreen({super.key});

  static const _tabs = [
    (label: 'الجديدة', status: 'accepted'),
    (label: 'قيد التنفيذ', status: 'in_progress'),
    (label: 'المكتملة', status: 'completed'),
    (label: 'الملغية', status: 'cancelled'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حجوزاتي'),
          bottom: TabBar(
            tabs: [for (final t in _tabs) Tab(text: t.label)],
            isScrollable: true,
            labelColor: SahelColors.primary700,
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              for (final t in _tabs) _ProviderBookingTab(status: t.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderBookingTab extends ConsumerWidget {
  final String status;
  const _ProviderBookingTab({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(
        providerBookingsProvider((status: status, date: null)));

    return bookings.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ShimmerCard(height: 76),
          SizedBox(height: 12),
          ShimmerCard(height: 76),
        ],
      ),
      error: (e, _) => Center(
        child: TextButton.icon(
          onPressed: () => ref.invalidate(providerBookingsProvider),
          icon: const Icon(Icons.refresh),
          label: const Text('إعادة المحاولة'),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Text('لا توجد حجوزات',
                style: TextStyle(
                    color: SahelColors.muted,
                    fontWeight: FontWeight.w700)),
          );
        }
        return RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(providerBookingsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _ProviderBookingTile(booking: items[i]),
          ),
        );
      },
    );
  }
}

class _ProviderBookingTile extends StatelessWidget {
  final Map<String, dynamic> booking;
  const _ProviderBookingTile({required this.booking});

  @override
  Widget build(BuildContext context) {
    final status =
        BookingStatusX.fromJson(str(booking['status'], 'pending'));
    final customer = asMap(booking['customer'] ?? booking['user']);
    final service = asMap(booking['service']);

    return GestureDetector(
      onTap: () => context.push('/p/bookings/${booking['id']}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: SahelColors.slate200),
        ),
        child: Row(
          children: [
            Container(
                width: 4,
                height: 52,
                decoration: BoxDecoration(
                    color: status == BookingStatus.inProgress
                        ? SahelColors.primary500
                        : status == BookingStatus.completed
                            ? SahelColors.green600
                            : status == BookingStatus.cancelled
                                ? SahelColors.red600
                                : SahelColors.amber500,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(str(service['name'], 'خدمة'),
                      style:
                          const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    [
                      str(customer['name'], 'عميل'),
                      str(booking['booking_date']),
                    ].where((e) => e.isNotEmpty).join(' · '),
                    style: const TextStyle(
                        color: SahelColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            BookingStatusPill(status: status),
          ],
        ),
      ),
    );
  }
}
