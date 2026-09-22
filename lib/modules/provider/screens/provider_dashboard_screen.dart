import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';
import '../../../shared/theme/sahel_colors.dart';

class ProviderDashboardScreen extends ConsumerWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dash = ref.watch(providerDashboardProvider);
    final bookings = ref.watch(
        providerBookingsProvider((status: 'pending', date: null)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(
            onPressed: () => context.push('/p/notifications'),
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            onPressed: () => context.push('/p/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: dash.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            ShimmerCard(height: 140),
            SizedBox(height: 16),
            ShimmerCard(height: 110),
            SizedBox(height: 16),
            ShimmerCard(height: 80),
          ],
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined,
                  size: 56, color: SahelColors.muted),
              const SizedBox(height: 12),
              const Text('تعذر تحميل لوحة التحكم',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: SahelColors.muted)),
              TextButton.icon(
                onPressed: () => ref.invalidate(providerDashboardProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
        data: (d) {
          final earnings = str(d['formatted_month_earnings'] ??
              d['month_earnings'] ??
              d['earnings_month'] ??
              '0');
          final totalBookings = str(d['total_bookings'] ?? d['bookings_count']);
          final rating = str(d['average_rating'] ?? d['rating']);
          final newCount = str(d['pending_bookings'] ?? d['new_requests']);
          final isOnline = toBool(d['is_available'] ?? d['is_online']);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(providerDashboardProvider);
              ref.invalidate(providerBookingsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF0D9488), Color(0xFF14B8A6)]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x4014B8A6),
                          blurRadius: 24,
                          offset: Offset(0, 8))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text('الأرباح الشهرية',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 13)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.black26,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isOnline ? 'متاح' : 'غير متاح',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(earnings,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 30)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _miniStat('الحجوزات',
                              totalBookings.isEmpty ? '0' : totalBookings,
                              Icons.calendar_month),
                          const SizedBox(width: 12),
                          _miniStat('التقييم',
                              rating.isEmpty ? '-' : rating, Icons.star),
                          const SizedBox(width: 12),
                          _miniStat('جديدة',
                              newCount.isEmpty ? '0' : newCount, Icons.bolt),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                        child: _card(Icons.list_alt, 'قائمة الخدمات',
                            () => context.push('/p/services'))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _card(Icons.calendar_today, 'التقويم',
                            () => context.push('/p/calendar'))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: _card(Icons.account_balance_wallet_outlined,
                            'سحب الرصيد', () => context.push('/p/withdraw'))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _card(Icons.verified_user_outlined, 'حالة KYC',
                            () => context.push('/p/kyc'))),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text('طلبات الحجز الجديدة',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/p/requests'),
                      child: const Text('عرض الكل',
                          style: TextStyle(
                              color: SahelColors.primary600,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                bookings.when(
                  loading: () => const ShimmerCard(height: 76),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (items) {
                    if (items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text('لا توجد طلبات جديدة',
                              style: TextStyle(color: SahelColors.muted)),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (final b in items.take(3))
                          _BookingPreview(booking: b),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _miniStat(String l, String v, IconData i) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Icon(i, size: 16, color: Colors.white),
            const SizedBox(height: 4),
            Text(v,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16)),
            Text(l,
                style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _card(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: SahelColors.slate200),
        ),
        child: Column(
          children: [
            Icon(icon, color: SahelColors.primary600, size: 26),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _BookingPreview extends StatelessWidget {
  final Map<String, dynamic> booking;
  const _BookingPreview({required this.booking});

  @override
  Widget build(BuildContext context) {
    final service = asMap(booking['service']);
    final customer = asMap(booking['customer'] ?? booking['user']);
    final price = str(booking['formatted_total'] ?? booking['total']);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
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
                  height: 50,
                  decoration: BoxDecoration(
                      color: SahelColors.amber500,
                      borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('طلب جديد - ${str(service['name'], 'خدمة')}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      [
                        str(customer['name']),
                        str(booking['booking_date'])
                      ].where((e) => e.isNotEmpty).join(' · '),
                      style: const TextStyle(
                          color: SahelColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(price,
                  style: const TextStyle(
                      color: SahelColors.primary700,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}
