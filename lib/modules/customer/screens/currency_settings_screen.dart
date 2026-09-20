import 'package:flutter/material.dart';
import '../../../shared/theme/sahel_colors.dart';

class CurrencySettingsScreen extends StatefulWidget {
  const CurrencySettingsScreen({super.key});

  @override
  State<CurrencySettingsScreen> createState() => _CurrencySettingsScreenState();
}

class _CurrencySettingsScreenState extends State<CurrencySettingsScreen> {
  String _selected = 'yer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('العملة')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _opt('yer', '🇾🇪', 'ريال يمني', 'YER', '﷼'),
            const SizedBox(height: 10),
            _opt('sar', '🇸🇦', 'ريال سعودي', 'SAR', 'ر.س'),
            const SizedBox(height: 10),
            _opt('aed', '🇦🇪', 'درهم إماراتي', 'AED', 'د.إ'),
          ],
        ),
      ),
    );
  }

  Widget _opt(String code, String flag, String t, String codeStr, String sym) {
    final selected = _selected == code;
    return GestureDetector(
      onTap: () => setState(() => _selected = code),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? SahelColors.primary500 : SahelColors.slate200,
              width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text('$codeStr · $sym', style: const TextStyle(color: SahelColors.muted, fontSize: 12)),
                ],
              ),
            ),
            if (selected)
              const CircleAvatar(radius: 12, backgroundColor: SahelColors.primary500,
                  child: Icon(Icons.check, size: 16, color: Colors.white))
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
