import 'package:flutter/material.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/service_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedCategory = 0;
  final List<String> _categories = const [
    'الكل',
    'تنظيفات',
    'سباكة',
    'كهرباء',
    'مكيفات',
    'نجارة',
    'دهانات',
    'غسيل',
  ];
  RangeValues _priceRange = const RangeValues(200, 800);
  bool _ratingFilter = false;
  bool _verifiedOnly = false;
  String? _selectedCity;
  final List<String> _cities = const [
    'صنعاء',
    'عدن',
    'تعز',
    'الحديدة',
    'إب',
    'ذمار',
    'مأرب',
    'البيضاء',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'البحث والتصفية',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchBar(
              hintText: 'ابحث باسم الخدمة أو الفني…',
              leading: const Icon(Icons.search, color: SahelColors.primary600),
              trailing: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.tune, color: SahelColors.primary600),
                ),
              ],
              backgroundColor: WidgetStateProperty.all(SahelColors.surface2),
              elevation: WidgetStateProperty.all(0),
              side: WidgetStateProperty.all(const BorderSide(color: SahelColors.border)),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: SahelRadii.pillRadius),
              ),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_categories.length, (i) {
                final selected = _selectedCategory == i;
                return ChoiceChip(
                  label: Text(_categories[i]),
                  selected: selected,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : SahelColors.text,
                  ),
                  selectedColor: SahelColors.primary600,
                  backgroundColor: SahelColors.surface2,
                  side: BorderSide(color: selected ? SahelColors.primary600 : SahelColors.border),
                  shape: RoundedRectangleBorder(borderRadius: SahelRadii.pillRadius),
                  onSelected: (_) => setState(() => _selectedCategory = i),
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'المدينة',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCity,
                        hint: const Text('اختر المدينة'),
                        items: _cities
                            .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedCity = v),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'السعر',
                          style: TextStyle(fontSize: 12, color: SahelColors.textMuted),
                        ),
                      ),
                      RangeSlider(
                        min: 50,
                        max: 2000,
                        divisions: 39,
                        values: _priceRange,
                        activeColor: SahelColors.primary600,
                        inactiveColor: SahelColors.surface3,
                        labels: RangeLabels(
                          '${_priceRange.start.round()} ر.س',
                          '${_priceRange.end.round()} ر.س',
                        ),
                        onChanged: (v) => setState(() => _priceRange = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    FilterChip(
                      avatar: const Icon(Icons.star, color: SahelColors.amber, size: 16),
                      label: const Text('4.5★ فأكثر'),
                      selected: _ratingFilter,
                      onSelected: (v) => setState(() => _ratingFilter = v),
                      selectedColor: SahelColors.amberSoft,
                      backgroundColor: SahelColors.surface2,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _ratingFilter ? SahelColors.amber : SahelColors.text,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: SahelRadii.pillRadius),
                    ),
                    const SizedBox(height: 8),
                    FilterChip(
                      label: const Text('الموثقين فقط'),
                      selected: _verifiedOnly,
                      onSelected: (v) => setState(() => _verifiedOnly = v),
                      selectedColor: SahelColors.primary50,
                      backgroundColor: SahelColors.surface2,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _verifiedOnly ? SahelColors.primary700 : SahelColors.text,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: SahelRadii.pillRadius),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.68,
              children: List.generate(12, (i) {
                final titles = [
                  'تنظيف شقق كامل',
                  'صيانة مكيفات سبليت',
                  'إصلاح تسريبات',
                  'تركيب كهربائي',
                  'دهان الجدران',
                  'غسيل الملابس',
                  'نجارة وتركيب',
                  'صيانة عامة',
                  'تنظيف السجاد',
                  'صيانة ثلاجات',
                  'تركيب أجهزة',
                  'تنظيف مواقد',
                ];
                final prices = [150.0, 200.0, 120.0, 180.0, 250.0, 80.0, 220.0, 160.0, 100.0, 190.0, 130.0, 110.0];
                return ServiceCard(
                  title: titles[i],
                  price: prices[i],
                  originalPrice: i % 3 == 0 ? prices[i] + 40 : null,
                  rating: 4.4 + (i % 6) * 0.1,
                  reviews: 50 + i * 7,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
