import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';
import '../../../shared/theme/sahel_colors.dart';

class CouponsScreen extends ConsumerWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupons = ref.watch(customerCouponsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الكوبونات والعروض')),
      body: SafeArea(
        child: coupons.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ShimmerCard(height: 90),
              SizedBox(height: 10),
              ShimmerCard(height: 90),
            ],
          ),
          error: (e, _) => Center(
            child: TextButton.icon(
              onPressed: () => ref.invalidate(customerCouponsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ),
          data: (items) => items.isEmpty
              ? const Center(
                  child: Text('لا توجد كوبونات متاحة حالياً',
                      style: TextStyle(color: SahelColors.muted)))
              : RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(customerCouponsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (ctx, i) {
                      final c = items[i];
                      final code = str(c['code']);
                      final pct = toDoubleOrNull(
                          c['discount_percent'] ?? c['percentage']);
                      final amount = toDoubleOrNull(
                          c['discount_amount'] ?? c['amount']);
                      final label = pct != null
                          ? 'خصم ${pct.toStringAsFixed(0)}%'
                          : amount != null
                              ? 'خصم ${amount.toStringAsFixed(0)}'
                              : str(c['title'] ?? c['name'], 'كوبون');
                      final expiry =
                          str(c['expires_at'] ?? c['valid_until']);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: SahelColors.amberSoft,
                            child: Icon(Icons.local_offer,
                                color: SahelColors.amber),
                          ),
                          title: Text(label,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800)),
                          subtitle: Text(
                            expiry.isEmpty
                                ? code
                                : '$code · ينتهي ${expiry.split('T').first}',
                            style: const TextStyle(
                                color: SahelColors.muted,
                                fontSize: 12),
                          ),
                          trailing: IconButton(
                            tooltip: 'نسخ الكود',
                            icon: const Icon(Icons.copy,
                                size: 18,
                                color: SahelColors.primary600),
                            onPressed: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: code));
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx)
                                    .showSnackBar(const SnackBar(
                                        content: Text(
                                            'تم نسخ الكود')));
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
