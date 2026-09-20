import 'package:flutter/material.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import '../../../shared/theme/sahel_colors.dart';

class WithdrawRequestScreen extends StatefulWidget {
  const WithdrawRequestScreen({super.key});

  @override
  State<WithdrawRequestScreen> createState() => _WithdrawRequestScreenState();
}

class _WithdrawRequestScreenState extends State<WithdrawRequestScreen> {
  String _method = 'bank';
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب سحب')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SahelColors.primary50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SahelColors.primary100),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.account_balance_wallet, color: SahelColors.primary600),
                    SizedBox(width: 10),
                    Expanded(child: Text('الرصيد المتاح: 42,500 ﷼',
                        style: TextStyle(fontWeight: FontWeight.w700, color: SahelColors.primary700))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('طريقة السحب', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              _methodTile('bank', 'تحويل بنكي', Icons.account_balance_outlined),
              const SizedBox(height: 10),
              _methodTile('wallet', 'محفظة إلكترونية', Icons.wallet_outlined),
              const SizedBox(height: 10),
              _methodTile('cash', 'استلام نقدي', Icons.payments_outlined),
              const SizedBox(height: 24),
              const Text('المبلغ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixText: '﷼ ',
                  labelText: 'أدخل المبلغ',
                  hintText: '10,000',
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [5000, 10000, 20000, 42500]
                    .map((e) => GestureDetector(
                          onTap: () => setState(() => _amountController.text = e.toString()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: SahelColors.slate100,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text('$e ﷼',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          ),
                        ))
                    .toList(),
              ),
              const Spacer(),
              SahelButton(
                label: 'إرسال طلب السحب',
                variant: SahelButtonVariant.gradient,
                onPressed: () {},
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: sel ? SahelColors.primary500 : SahelColors.slate200,
            width: sel ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(i, color: SahelColors.primary600),
            const SizedBox(width: 12),
            Expanded(child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700))),
            if (sel)
              const CircleAvatar(radius: 10, backgroundColor: SahelColors.primary500,
                  child: Icon(Icons.check, size: 14, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
