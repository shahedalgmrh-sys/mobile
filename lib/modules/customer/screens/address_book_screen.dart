import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';
import '../../../shared/theme/sahel_colors.dart';

class AddressBookScreen extends ConsumerWidget {
  const AddressBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(customerAddressesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('دفتر العناوين'), actions: [
        IconButton(
            onPressed: () => _addAddress(context, ref),
            icon: const Icon(Icons.add)),
      ]),
      body: SafeArea(
        child: addresses.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ShimmerCard(height: 100),
              SizedBox(height: 10),
              ShimmerCard(height: 100),
            ],
          ),
          error: (e, _) => Center(
            child: TextButton.icon(
              onPressed: () =>
                  ref.invalidate(customerAddressesProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ),
          data: (items) => RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(customerAddressesProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final a in items) _AddressTile(address: a),
                const SizedBox(height: 24),
                SahelButton.soft(
                    label: 'إضافة عنوان جديد',
                    onTap: () => _addAddress(context, ref),
                    prefixIcon: Icons.add_location_alt_outlined),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addAddress(BuildContext context, WidgetRef ref) {
    final label = TextEditingController();
    final address = TextEditingController();
    final phone = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('عنوان جديد',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(
                controller: label,
                decoration: const InputDecoration(
                    labelText: 'الاسم (المنزل، العمل…)')),
            const SizedBox(height: 12),
            TextField(
                controller: address,
                decoration: const InputDecoration(
                    labelText: 'العنوان الكامل')),
            const SizedBox(height: 12),
            TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(labelText: 'رقم الهاتف')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: SahelButton(
                label: 'حفظ العنوان',
                variant: SahelButtonVariant.gradient,
                onPressed: () async {
                  try {
                    await ref
                        .read(customerRepositoryProvider)
                        .storeAddress({
                      'label': label.text.trim(),
                      'address': address.text.trim(),
                      'phone': phone.text.trim(),
                    });
                    ref.invalidate(customerAddressesProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (_) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('تعذر حفظ العنوان')));
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressTile extends ConsumerWidget {
  final Map<String, dynamic> address;
  const _AddressTile({required this.address});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = toBool(address['is_default'] ??
        address['is_primary'] ??
        address['isDefault']);
    final label = str(address['label'] ?? address['title'], 'عنوان');
    final body = str(address['full_address'] ??
        address['address'] ??
        address['address_line']);
    final phone = str(address['phone']);
    final id = toInt(address['id']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: primary
                ? SahelColors.primary400
                : SahelColors.slate200,
            width: primary ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.home_outlined,
                  color: SahelColors.primary600),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const Spacer(),
              if (primary)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: SahelColors.primary100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('افتراضي',
                      style: TextStyle(
                          color: SahelColors.primary700,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(
                  color: SahelColors.muted, height: 1.4)),
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.phone,
                    size: 14, color: SahelColors.muted),
                const SizedBox(width: 4),
                Text(phone,
                    style: const TextStyle(
                        color: SahelColors.muted, fontSize: 12)),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    try {
                      await ref
                          .read(customerRepositoryProvider)
                          .destroyAddress(id);
                      ref.invalidate(customerAddressesProvider);
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('تعذر حذف العنوان')));
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_outline,
                      color: SahelColors.red600, size: 20),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
