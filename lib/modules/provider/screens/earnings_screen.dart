import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';
import '../../../shared/theme/sahel_colors.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(providerWalletProvider);
    final withdrawals = ref.watch(providerWithdrawalsProvider);
    final bookings = ref.watch(
        providerBookingsProvider((status: 'completed', date: null)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأرباح'),
        actions: [
          TextButton(
              onPressed: () => context.push('/p/withdraw'),
              child: const Text('سحب')),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(providerWalletProvider);
            ref.invalidate(providerWithdrawalsProvider);
            ref.invalidate(providerBookingsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              wallet.when(
                loading: () => const ShimmerCard(height: 130),
                error: (_, __) => const SizedBox.shrink(),
                data: (w) => Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: SahelColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الرصيد المتاح للسحب',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(
                        str(w['formatted_available'] ??
                            w['formatted_balance'] ??
                            w['balance'] ??
                            w['available_balance'],
                            '0'),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 32),
                      ),
                      const SizedBox(height: 20),
                      const Text('إجمالي الأرباح',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              str(w['formatted_total_earnings'] ??
                                  w['total_earnings'],
                                  '—'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          const Icon(Icons.trending_up,
                              color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              bookings.when(
                loading: () => const ShimmerCard(height: 80),
                error: (_, __) => const SizedBox.shrink(),
                data: (items) => Row(
                  children: [
                    Expanded(
                        child: _metric('الحجوزات المنجزة',
                            '${items.length}', SahelColors.primary600)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('طلبات السحب',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              withdrawals.when(
                loading: () => const ShimmerCard(height: 100),
                error: (_, __) => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text('تعذر تحميل السحوبات',
                        style: TextStyle(color: SahelColors.muted)),
                  ),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text('لا توجد طلبات سحب بعد',
                            style: TextStyle(color: SahelColors.muted)),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final w in items) _withdrawalTile(w),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(String l, String v, Color c) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SahelColors.slate200),
      ),
      child: Column(
        children: [
          Text(v,
              style: TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 20, color: c)),
          const SizedBox(height: 4),
          Text(l,
              style: const TextStyle(
                  fontSize: 11, color: SahelColors.muted)),
        ],
      ),
    );
  }

  Widget _withdrawalTile(Map<String, dynamic> w) {
    final status = str(w['status']);
    final color = status == 'paid' || status == 'completed'
        ? SahelColors.green600
        : status == 'rejected' || status == 'cancelled'
            ? SahelColors.red600
            : SahelColors.amber500;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SahelColors.slate200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'سحب - ${str(w['bank_name'] ?? w['method'], 'تحويل')}',
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(str(w['created_at']).substring(
                        0,
                        str(w['created_at']).length > 10
                            ? 10
                            : str(w['created_at']).length),
                    style: const TextStyle(
                        fontSize: 12, color: SahelColors.muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                  '-${str(w['formatted_amount'] ?? w['amount'])}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: SahelColors.red600)),
              Text(status,
                  style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
