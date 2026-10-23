import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';

final walletStatementProvider = FutureProvider
    .autoDispose<List<Map<String, dynamic>>>((ref) async {
  final data = await ref.read(customerRepositoryProvider).reports('wallet');
  final d = asMap(data);
  return dataList(
    d['items'] ?? d['transactions'] ?? d['wallet_transactions'] ?? data,
  );
});

/// Mirrors the website `/wallet/statement` page via `/customer/reports/wallet`.
class WalletStatementScreen extends ConsumerWidget {
  const WalletStatementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statement = ref.watch(walletStatementProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('كشف حساب المحفظة')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(walletStatementProvider),
        child: statement.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: TextButton.icon(
              onPressed: () => ref.invalidate(walletStatementProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(children: const [
                Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text('لا توجد عمليات في الكشف بعد',
                        style: TextStyle(color: SahelColors.textMuted)),
                  ),
                ),
              ]);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: SahelColors.slate200),
              itemBuilder: (ctx, i) => _StatementRow(tx: items[i]),
            );
          },
        ),
      ),
    );
  }
}

class _StatementRow extends StatelessWidget {
  final Map<String, dynamic> tx;
  const _StatementRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    final type = str(tx['type']).toLowerCase();
    final isCredit = type.contains('topup') ||
        type.contains('refund') ||
        type.contains('credit') ||
        type.contains('earning') ||
        type.contains('add');
    final color = isCredit ? SahelColors.success : SahelColors.danger;
    final desc = str(
      tx['description'] ?? tx['title'] ?? tx['notes'] ?? type,
      'عملية',
    );
    final amount = str(tx['formatted_amount'] ?? tx['amount']);
    final balance =
        strOrNull(tx['balance_after'] ?? tx['ending_balance']);
    final date = str(tx['date_ar'] ??
        tx['formatted_created_at'] ??
        tx['created_at']);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(desc,
          maxLines: 2, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (date.isNotEmpty) Text(date, style: const TextStyle(fontSize: 11, color: SahelColors.textMuted)),
          if (balance != null)
            Text('الرصيد بعد العملية: $balance',
                style: const TextStyle(fontSize: 11, color: SahelColors.textMuted)),
        ],
      ),
      trailing: Text(
        '${isCredit ? '+' : '−'}$amount',
        style: TextStyle(fontWeight: FontWeight.w800, color: color),
      ),
      shape: const RoundedRectangleBorder(borderRadius: SahelRadii.mdRadius),
    );
  }
}
