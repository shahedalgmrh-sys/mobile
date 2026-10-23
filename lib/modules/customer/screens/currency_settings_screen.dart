import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/settings_provider.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';

final catalogCurrenciesProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) => ref.watch(catalogRepositoryProvider).currencies(),
);

class CurrencySettingsScreen extends ConsumerWidget {
  const CurrencySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(appSettingsProvider).currency;
    final currencies = ref.watch(catalogCurrenciesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('العملة')),
      body: SafeArea(
        child: currencies.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              SizedBox(height: 80),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (_, __) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _opt(ref, selected, 'yer', 'ريال يمني', 'YER · ﷼'),
              const SizedBox(height: 10),
              _opt(ref, selected, 'sar', 'ريال سعودي', 'SAR · ر.س'),
              const SizedBox(height: 10),
              _opt(ref, selected, 'usd', 'دولار أمريكي', 'USD · \$'),
            ],
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _opt(ref, selected, 'yer', 'ريال يمني', 'YER · ﷼'),
                  const SizedBox(height: 10),
                  _opt(ref, selected, 'sar', 'ريال سعودي', 'SAR · ر.س'),
                  const SizedBox(height: 10),
                  _opt(ref, selected, 'usd', 'دولار أمريكي', 'USD · \$'),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _opt(
                    ref,
                    selected,
                    str(items[i]['code'] ?? items[i]['currency_code']).toLowerCase(),
                    str(items[i]['name'] ?? items[i]['name_ar'] ?? items[i]['title'],
                        'عملة'),
                    '${str(items[i]['code'] ?? items[i]['currency_code']).toUpperCase()} · ${str(items[i]['symbol'], '')}',
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _opt(WidgetRef ref, String selected, String code, String t, String sub) {
    final isSelected = selected == code;
    return GestureDetector(
      onTap: () => ref.read(appSettingsProvider.notifier).setCurrency(code),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SahelColors.onPrimary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isSelected ? SahelColors.primary500 : SahelColors.slate200,
              width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: const TextStyle(
                          color: SahelColors.muted, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              const CircleAvatar(
                  radius: 12,
                  backgroundColor: SahelColors.primary500,
                  child: Icon(Icons.check, size: 16, color: SahelColors.onPrimary)),
          ],
        ),
      ),
    );
  }
}
