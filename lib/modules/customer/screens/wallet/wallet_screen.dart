import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(customerWalletProvider);
    final txs = ref.watch(walletTransactionsProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180),
        child: Container(
          decoration: const BoxDecoration(gradient: SahelColors.nightGradient),
          child: SafeArea(
            child: Center(
              child: wallet.when(
                loading: () => const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
                error: (_, __) => const Text('—',
                    style: TextStyle(color: Colors.white, fontSize: 32)),
                data: (w) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'رصيد المحفظة',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      str(w['formatted_balance'] ?? w['balance'], '0'),
                      style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1),
                    ),
                    Text(
                      str(w['currency'] ?? w['display_currency'],
                          '').toUpperCase(),
                      style: const TextStyle(
                          fontSize: 15,
                          color: SahelColors.primary200,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(customerWalletProvider);
          ref.invalidate(walletTransactionsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: SahelButton.gradient(
                    icon: Icons.add,
                    label: 'شحن الرصيد',
                    onPressed: () => _showAddFunds(context, ref),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SahelButton.soft(
                    icon: Icons.receipt_long,
                    label: 'كشف الحساب',
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('آخر العمليات',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton(
                  onPressed: () => ref.invalidate(walletTransactionsProvider),
                  child: const Text('تحديث',
                      style: TextStyle(
                          color: SahelColors.primary700,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            txs.when(
              loading: () => const ShimmerCard(height: 160),
              error: (e, _) => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('تعذر تحميل العمليات',
                      style: TextStyle(color: SahelColors.textMuted)),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('لا توجد عمليات بعد',
                          style: TextStyle(color: SahelColors.textMuted)),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) => _TxTile(tx: items[i]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFunds(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('شحن المحفظة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: SahelButton.gradient(
                label: 'تأكيد الشحن',
                onPressed: () async {
                  final amount = double.tryParse(controller.text.trim());
                  if (amount == null || amount <= 0) return;
                  Navigator.of(ctx).pop();
                  // TODO: pick payment method UI; default wallet/card.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('جاري معالجة الشحن…')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  final Map<String, dynamic> tx;
  const _TxTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final type = str(tx['type']).toLowerCase();
    final isCredit = type.contains('topup') ||
        type.contains('refund') ||
        type.contains('credit') ||
        type.contains('earning') ||
        type.contains('add');
    final isDebit = !isCredit;
    final iconColor = isCredit ? SahelColors.success : SahelColors.danger;
    final iconBg = isCredit ? SahelColors.successSoft : SahelColors.dangerSoft;
    final icon = isCredit ? Icons.add : Icons.remove;
    final amount = str(tx['formatted_amount'] ?? tx['amount']);
    final title = str(tx['description'] ?? tx['title'] ?? type, 'عملية');
    final subtitle = str(tx['created_at'] ?? tx['date']);

    return Material(
      color: SahelColors.surface,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: SahelRadii.smRadius,
            color: iconBg,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title,
            style:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                fontSize: 11, color: SahelColors.textMuted)),
        trailing: Text(
          '${isDebit ? '−' : '+'}$amount',
          style: TextStyle(
              fontWeight: FontWeight.w800, fontSize: 14, color: iconColor),
        ),
      ),
    );
  }
}
