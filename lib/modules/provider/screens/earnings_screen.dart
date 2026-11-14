import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/core/errors/failures.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/core/utils/format.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(providerWalletProvider);
    final withdrawals = ref.watch(providerWithdrawalsProvider);
    final dash = ref.watch(providerDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأرباح'),
        actions: [
          TextButton(
            onPressed: () => context.push('/p/withdraw'),
            child: const Text('سحب'),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(providerWalletProvider);
            ref.invalidate(providerWithdrawalsProvider);
            ref.invalidate(providerDashboardProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              wallet.when(
                loading: () => const ShimmerCard(height: 130),
                error: (_, __) => const SizedBox.shrink(),
                data: (w) {
                  final currency = str(w['currency']);
                  final balance = formatMoney(
                    w['balance'] ?? w['available_balance'] ?? 0,
                  );
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: SahelColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'رصيد المحفظة',
                          style: TextStyle(
                            color: SahelColors.onPrimary70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currency.isEmpty ? balance : '$balance $currency',
                          style: const TextStyle(
                            color: SahelColors.onPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'قد يقل المبلغ القابل للسحب عن الرصيد بسبب المبالغ المحجوزة أو طلبات السحب المعلقة.',
                          style: TextStyle(
                            color: SahelColors.onPrimary70,
                            fontSize: 10,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'إجمالي الأرباح المدفوعة',
                          style: TextStyle(
                            color: SahelColors.onPrimary70,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: dash.when(
                                loading: () => const Text(
                                  '…',
                                  style: TextStyle(
                                    color: SahelColors.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                // The wallet payload has no total; do not fake it.
                                error: (_, __) => const Text(
                                  'غير متاح',
                                  style: TextStyle(
                                    color: SahelColors.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                data: (d) {
                                  final total = toDoubleOrNull(
                                    asMap(d['metrics'])['total_earnings'],
                                  );
                                  return Text(
                                    total == null
                                        ? 'غير متاح'
                                        : NumberFormat(
                                            '#,##0.00',
                                            'en',
                                          ).format(total),
                                    style: const TextStyle(
                                      color: SahelColors.onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const Icon(
                              Icons.trending_up,
                              color: SahelColors.onPrimary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'صافي أرباح الحجوزات المدفوعة بعد عمولة المنصة — كل الفترات',
                          style: TextStyle(
                            color: SahelColors.onPrimary70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              dash.when(
                loading: () => const ShimmerCard(height: 80),
                error: (_, __) => const SizedBox.shrink(),
                data: (d) {
                  final metrics = asMap(d['metrics']);
                  final completed = metrics['completed_bookings'];
                  return Row(
                    children: [
                      Expanded(
                        child: _metric(
                          'الحجوزات المنجزة',
                          str(completed, '—'),
                          SahelColors.primary600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _metric(
                          'حجوزات اليوم',
                          str(metrics['today_bookings'], '—'),
                          SahelColors.amber600,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'طلبات السحب',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 12),
              withdrawals.when(
                loading: () => const ShimmerCard(height: 100),
                error: (_, __) => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'تعذر تحميل السحوبات',
                      style: TextStyle(color: SahelColors.muted),
                    ),
                  ),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'لا توجد طلبات سحب بعد',
                          style: TextStyle(color: SahelColors.muted),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final w in items) _withdrawalTile(context, ref, w),
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
        color: SahelColors.onPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SahelColors.slate200),
      ),
      child: Column(
        children: [
          Text(
            v,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: c,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l,
            style: const TextStyle(fontSize: 11, color: SahelColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _withdrawalTile(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> w,
  ) {
    final status = str(w['status']);
    final color = status == 'paid' || status == 'completed'
        ? SahelColors.green600
        : status == 'rejected' || status == 'cancelled'
        ? SahelColors.red600
        : SahelColors.amber500;
    final cancellable = status == 'pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SahelColors.onPrimary,
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
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  str(w['created_at']).substring(
                    0,
                    str(w['created_at']).length > 10
                        ? 10
                        : str(w['created_at']).length,
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: SahelColors.muted,
                  ),
                ),
                if (cancellable)
                  TextButton.icon(
                    onPressed: () =>
                        _cancelWithdrawal(context, ref, str(w['id'])),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      minimumSize: const Size(0, 28),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(
                      Icons.close,
                      size: 14,
                      color: SahelColors.red600,
                    ),
                    label: const Text(
                      'إلغاء الطلب',
                      style: TextStyle(fontSize: 11, color: SahelColors.red600),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${formatMoney(w['amount'])}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: SahelColors.red600,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Mirrors `POST /provider/withdrawals/{id}/cancel` — server refuses
  /// non-pending requests (422), surfaced verbatim here.
  Future<void> _cancelWithdrawal(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إلغاء طلب السحب؟'),
        content: const Text('سيعود المبلغ المطلوب إلى رصيدك المتاح.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(providerRepositoryProvider).cancelWithdrawal(id);
      ref.invalidate(providerWithdrawalsProvider);
      ref.invalidate(providerWalletProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(const SnackBar(content: Text('تم إلغاء طلب السحب ✓')));
      }
    } catch (e) {
      String msg = 'تعذر إلغاء الطلب';
      if (e is ApiException) {
        final f = e.failure;
        if (f is ServerFailure && f.message.isNotEmpty) msg = f.message;
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: SahelColors.danger),
          );
      }
    }
  }
}
