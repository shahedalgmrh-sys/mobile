import 'package:flutter/material.dart';
import '../../../shared/theme/sahel_colors.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';

class ServiceCatalogScreen extends StatelessWidget {
  const ServiceCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: SahelColors.primary600,
        foregroundColor: Colors.white,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(title: const Text('كتالوج الخدمات')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _svc('تنظيف منزلي', 'خدمة تنظيف شامل للمنازل', 1500, true, 4.8, 312),
            const SizedBox(height: 12),
            _svc('صيانة تكييف', 'فحص وصيانة وتنظيف مكيفات سبليت', 2000, true, 4.6, 187),
            const SizedBox(height: 12),
            _svc('خدمات كهربائية', 'اصلاح وتركيب وتشطيب كهربائي', 1800, false, 4.4, 94),
            const SizedBox(height: 12),
            _svc('سباكة', 'اصلاح أنابيب وتركيب أدوات صحية', 1900, true, 4.7, 120),
          ],
        ),
      ),
    );
  }

  Widget _svc(String t, String desc, double p, bool active, double rate, int rev) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SahelColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(desc, style: const TextStyle(color: SahelColors.muted, fontSize: 12, height: 1.4)),
                  ],
                ),
              ),
              Switch(
                value: active,
                onChanged: (_) {},
                activeTrackColor: SahelColors.primary200,
                activeColor: SahelColors.primary600,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: SahelColors.amber500),
              const SizedBox(width: 2),
              Text('$rate ($rev)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${p.toStringAsFixed(0)} ﷼',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: SahelColors.primary700, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: SahelButton.soft(label: 'تعديل', onTap: () {}, height: 36, width: 0)),
              const SizedBox(width: 8),
              Expanded(
                  child: SahelButton(label: 'الحجوزات', variant: SahelButtonVariant.outline, onPressed: () {}, height: 36, width: 0)),
            ],
          ),
        ],
      ),
    );
  }
}
