import 'package:flutter/material.dart';
import 'package:saber_flutter/core/i18n/sahel_i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/core/errors/failures.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
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
                      'رصيد المحفظة'.t(lang),
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
                    label: 'شحن الرصيد'.t(lang),
                    onPressed: () => _showAddFunds(context, ref),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SahelButton.soft(
                    icon: Icons.receipt_long,
                    label: 'كشف الحساب'.t(lang),
                    onPressed: () => context.push('/wallet/statement'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('آخر العمليات'.t(lang),
                    style:
                        const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton(
                  onPressed: () => ref.invalidate(walletTransactionsProvider),
                  child: Text('تحديث'.t(lang),
                      style: const TextStyle(
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

  static const _paymentMethods = <(String id, String label, IconData icon)>[
    ('mada', 'مدى', Icons.credit_card),
    ('stc_pay', 'STC Pay', Icons.phone_android),
    ('apple_pay', 'Apple Pay', Icons.phone_iphone),
    ('google_pay', 'Google Pay', Icons.currency_rupee),
    ('stripe', 'بطاقة (Visa/Master)', Icons.account_balance),
    ('paypal', 'PayPal', Icons.public),
  ];

  void _showAddFunds(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    String method = _paymentMethods.first.$1;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('شحن المحفظة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('المبلغ المسموح: 10 – 50,000 ريال',
                  style: TextStyle(fontSize: 12, color: SahelColors.textMuted)),
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
              const Text('وسيلة الدفع',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (id, label, icon) in _paymentMethods)
                    FilterChip(
                      selected: method == id,
                      onSelected: (_) => setSheet(() => method = id),
                      avatar: Icon(icon,
                          size: 16,
                          color: method == id
                              ? Colors.white
                              : SahelColors.primary600),
                      label: Text(label,
                          style: const TextStyle(fontSize: 12)),
                      selectedColor: SahelColors.primary600,
                      checkmarkColor: Colors.white,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: SahelButton.gradient(
                  label: 'تأكيد الشحن',
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await _submitTopUp(
                      context,
                      ref,
                      double.tryParse(controller.text.trim()) ?? 0,
                      method,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitTopUp(
    BuildContext context,
    WidgetRef ref,
    double amount,
    String method,
  ) async {
    if (amount < 10 || amount > 50000) {
      _snack(context, 'المبلغ يجب أن يكون بين 10 و 50,000 ريال', error: true);
      return;
    }
    _snack(context, 'جاري إنشاء طلب الشحن…');
    try {
      final payment = await ref
          .read(customerRepositoryProvider)
          .addFunds(amount, method);
      final paymentId = str(payment['payment_id'] ?? payment['id']);
      if (!context.mounted || paymentId.isEmpty) return;
      final checkoutUrl = strOrNull(payment['checkout_url']);
      _showPendingPayment(context, ref, paymentId, checkoutUrl,
          str(payment['formatted_amount'] ?? payment['amount'], '$amount'));
    } catch (e) {
      if (context.mounted) _snack(context, _failureMessage(e), error: true);
    }
  }

  /// Mirrors the server contract: create intent → complete payment at the
  /// gateway (`checkout_url`) → confirm to credit the wallet.
  void _showPendingPayment(
    BuildContext context,
    WidgetRef ref,
    String paymentId,
    String? checkoutUrl,
    String amount,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('بانتظار إتمام الدفع'),
        content: Text(
            'تم إنشاء طلب شحن بقيمة $amount. أكمل الدفع عبر بوابة الدفع ثم أكّد العملية لتُضاف إلى محفظتك.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('لاحقًا'),
          ),
          if (checkoutUrl != null)
            TextButton.icon(
              onPressed: () async {
                await _openCheckout(checkoutUrl);
              },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('فتح صفحة الدفع'),
            ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await _confirmTopUp(context, ref, paymentId);
            },
            icon: const Icon(Icons.verified_outlined, size: 18),
            label: const Text('تم الدفع — تأكيد'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmTopUp(
    BuildContext context,
    WidgetRef ref,
    String paymentId,
  ) async {
    _snack(context, 'جاري تأكيد الدفع…');
    try {
      await ref
          .read(customerRepositoryProvider)
          .confirmWalletPayment(paymentId);
      ref.invalidate(customerWalletProvider);
      ref.invalidate(walletTransactionsProvider);
      ref.invalidate(customerPaymentsProvider);
      if (context.mounted) {
        _snack(context, 'تم شحن المحفظة بنجاح ✓');
      }
    } catch (e) {
      if (context.mounted) _snack(context, _failureMessage(e), error: true);
    }
  }

  static Future<void> _openCheckout(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static void _snack(BuildContext context, String message,
      {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: error ? SahelColors.danger : null,
      ));
  }

  /// Human-readable message from a wrapped [ApiException] failure.
  static String _failureMessage(Object e) {
    if (e is ApiException) {
      final f = e.failure;
      if (f is ServerFailure) return f.message;
      if (f is BusinessRuleFailure) return f.message;
      if (f is ValidationFailure) {
        final first = f.errors.values.expand((v) => v).firstOrNull;
        if (first != null) return first;
      }
    }
    return 'تعذر إتمام العملية — تحقق من الاتصال وحاول مجددًا';
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
