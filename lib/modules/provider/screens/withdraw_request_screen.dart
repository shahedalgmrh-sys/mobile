import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';

class WithdrawRequestScreen extends ConsumerStatefulWidget {
  const WithdrawRequestScreen({super.key});

  @override
  ConsumerState<WithdrawRequestScreen> createState() =>
      _WithdrawRequestScreenState();
}

class _WithdrawRequestScreenState
    extends ConsumerState<WithdrawRequestScreen> {
  String _method = 'bank_transfer';
  final _amountController = TextEditingController();
  final _ibanController = TextEditingController();
  final _bankController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _amountController.dispose();
    _ibanController.dispose();
    _bankController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('أدخل مبلغاً صحيحاً')));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(providerRepositoryProvider).storeWithdrawal({
        'amount': amount,
        'method': _method,
        if (_ibanController.text.trim().isNotEmpty)
          'iban': _ibanController.text.trim(),
        if (_bankController.text.trim().isNotEmpty)
          'bank_name': _bankController.text.trim(),
      });
      ref.invalidate(providerWithdrawalsProvider);
      ref.invalidate(providerWalletProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تم إرسال طلب السحب بنجاح')));
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر إرسال الطلب')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(providerWalletProvider);
    final balance = wallet.maybeWhen(
      data: (w) => str(
          w['formatted_available'] ??
              w['formatted_balance'] ??
              w['balance'],
          '—'),
      orElse: () => '—',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('طلب سحب')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SahelColors.primary50,
                  borderRadius: SahelRadii.mdRadius,
                  border:
                      Border.all(color: SahelColors.primary100),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet,
                        color: SahelColors.primary600),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text('الرصيد المتاح: $balance',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: SahelColors.primary700))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('طريقة السحب',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              _methodTile('bank_transfer', 'تحويل بنكي',
                  Icons.account_balance_outlined),
              const SizedBox(height: 10),
              _methodTile(
                  'wallet', 'محفظة إلكترونية', Icons.wallet_outlined),
              const SizedBox(height: 24),
              if (_method == 'bank_transfer') ...[
                TextField(
                  controller: _bankController,
                  decoration:
                      const InputDecoration(labelText: 'اسم البنك'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _ibanController,
                  decoration: const InputDecoration(
                      labelText: 'IBAN / رقم الحساب'),
                ),
                const SizedBox(height: 24),
              ],
              const Text('المبلغ',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                        decimal: true),
                decoration: const InputDecoration(
                  labelText: 'أدخل المبلغ',
                ),
              ),
              const SizedBox(height: 32),
              _busy
                  ? const Center(child: CircularProgressIndicator())
                  : SahelButton(
                      label: 'إرسال طلب السحب',
                      variant: SahelButtonVariant.gradient,
                      onPressed: _submit,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _methodTile(String k, String t, IconData i) {
    final sel = _method == k;
    return GestureDetector(
      onTap: () => setState(() => _method = k),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SahelColors.onPrimary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                sel ? SahelColors.primary500 : SahelColors.slate200,
            width: sel ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(i, color: SahelColors.primary600),
            const SizedBox(width: 12),
            Expanded(
                child: Text(t,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700))),
            if (sel)
              const CircleAvatar(
                  radius: 10,
                  backgroundColor: SahelColors.primary500,
                  child: Icon(Icons.check,
                      size: 14, color: SahelColors.onPrimary)),
          ],
        ),
      ),
    );
  }
}
