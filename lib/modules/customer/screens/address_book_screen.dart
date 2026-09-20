import 'package:flutter/material.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import '../../../shared/theme/sahel_colors.dart';
import 'package:saber_flutter/core/constants/enums.dart';

class AddressBookScreen extends StatelessWidget {
  const AddressBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دفتر العناوين'), actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
      ]),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _address(true, 'المنزل', Icons.home_outlined,
                'شارع حيلة، بناية 12، شقة 3، صنعاء، اليمن', '+967 777 123 456'),
            const SizedBox(height: 10),
            _address(false, 'العمل', Icons.business_outlined,
                'مول الريان، الطابق 5، مكتب 502، شارع 60، صنعاء', '+967 1 555 666'),
            const SizedBox(height: 24),
            SahelButton.soft(
                label: 'إضافة عنوان جديد',
                onTap: () {},
                prefixIcon: Icons.add_location_alt_outlined),
          ],
        ),
      ),
    );
  }

  Widget _address(bool primary, String t, IconData i, String a, String phone) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: primary ? SahelColors.primary400 : SahelColors.slate200,
            width: primary ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(i, color: SahelColors.primary600),
              const SizedBox(width: 8),
              Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const Spacer(),
              if (primary)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: SahelColors.primary100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('افتراضي',
                      style: TextStyle(color: SahelColors.primary700, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(a, style: const TextStyle(color: SahelColors.muted, height: 1.4)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.phone, size: 14, color: SahelColors.muted),
              const SizedBox(width: 4),
              Text(phone, style: const TextStyle(color: SahelColors.muted, fontSize: 12)),
              const Spacer(),
              IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, color: SahelColors.muted, size: 20)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline, color: SahelColors.red600, size: 20)),
            ],
          ),
        ],
      ),
    );
  }
}
