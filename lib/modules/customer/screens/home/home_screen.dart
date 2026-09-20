import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/category_tile.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/shared/widgets/service_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleMedium = Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700) ??
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: SahelColors.text);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(135 * 3.1415926535 / 180),
              colors: [Color(0xFF0F172A), Color(0xFF134E4A), Color(0xFF115E59)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.location_on, color: Colors.white),
                      ),
                      const Expanded(
                        child: Text(
                          '📍 Sana\'a, Algiers st.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Stack(
                        children: [
                          const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: CircleAvatar(
                              radius: 6,
                              backgroundColor: SahelColors.amber,
                              child: const Text(
                                '2',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: SahelRadii.pillRadius,
                      boxShadow: [BoxShadow(color: SahelColors.shadowSm, blurRadius: 4, offset: Offset(0, 1))],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'ابحث عن خدمة، فني، تصنيف…',
                        hintStyle: const TextStyle(color: SahelColors.textSoft, fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: SahelColors.primary600),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(5),
                          child: SahelButton.amber(
                            height: 36,
                            width: 80,
                            label: 'بحث',
                            onPressed: () {},
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              Text('تصفح حسب التصنيف', style: titleMedium),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'عرض الكل >',
                  style: TextStyle(color: SahelColors.primary700, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            primary: false,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              CategoryTile(
                icon: Icons.cleaning_services,
                label: 'تنظيف',
                color: SahelColors.primary600,
                bgColor: SahelColors.primary50,
              ),
              CategoryTile(
                icon: Icons.plumbing,
                label: 'سباكة',
                color: SahelColors.info,
                bgColor: SahelColors.infoSoft,
              ),
              CategoryTile(
                icon: Icons.electrical_services,
                label: 'كهرباء',
                color: SahelColors.amber,
                bgColor: SahelColors.amberSoft,
              ),
              CategoryTile(
                icon: Icons.home_repair_service,
                label: 'صيانة عامة',
                color: SahelColors.violet,
                bgColor: SahelColors.violetSoft,
              ),
              CategoryTile(
                icon: Icons.air,
                label: 'مكيفات',
                color: SahelColors.success,
                bgColor: SahelColors.successSoft,
              ),
              CategoryTile(
                icon: Icons.carpenter,
                label: 'نجارة',
                color: SahelColors.warning,
                bgColor: SahelColors.warningSoft,
              ),
              CategoryTile(
                icon: Icons.format_paint,
                label: 'دهانات',
                color: SahelColors.danger,
                bgColor: SahelColors.dangerSoft,
              ),
              CategoryTile(
                icon: Icons.local_laundry_service,
                label: 'غسيل',
                color: SahelColors.slate,
                bgColor: SahelColors.surface3,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: SahelColors.warmGradient,
                  borderRadius: SahelRadii.lgRadius,
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.local_offer, color: Colors.white, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'خصم 25% لخدمة تنظيف شقق 3 غرف',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'العرض ساري حتى نهاية الشهر',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SahelButton.whiteBgPrimaryText(
                      label: 'استفد الآن',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('الخدمات الأعلى تقييماً', style: titleMedium),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'عرض الكل >',
                  style: TextStyle(color: SahelColors.primary700, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 280,
            child: ListView.separated(
              shrinkWrap: true,
              primary: false,
              scrollDirection: Axis.horizontal,
              itemCount: 8,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (ctx, i) {
                final titles = [
                  'تنظيف شقق كامل',
                  'صيانة مكيفات سبليت',
                  'إصلاح تسريبات السباكة',
                  'تركيب كهربائي منزلي',
                  'دهان وتجديد الجدران',
                  'غسيل وتنظيف الملابس',
                  'نجارة وتركيب أثاث',
                  'صيانة عامة للمنزل',
                ];
                final prices = [150.0, 200.0, 120.0, 180.0, 250.0, 80.0, 220.0, 160.0];
                final icons = [
                  Icons.cleaning_services,
                  Icons.air,
                  Icons.plumbing,
                  Icons.electrical_services,
                  Icons.format_paint,
                  Icons.local_laundry_service,
                  Icons.carpenter,
                  Icons.home_repair_service,
                ];
                return ServiceCard(
                  title: titles[i],
                  price: prices[i],
                  originalPrice: i % 2 == 0 ? prices[i] + 50 : null,
                  icon: icons[i],
                  rating: 4.5 + (i % 5) * 0.1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
