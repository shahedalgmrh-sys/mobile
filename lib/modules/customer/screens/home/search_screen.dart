import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/models/service.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/service_card.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  int? _categoryId;
  RangeValues _priceRange = const RangeValues(200, 800);
  bool _ratingFilter = false;
  int? _cityId;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQuery(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      setState(() => _query = v.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const [];
    final cities = ref.watch(citiesProvider).valueOrNull ?? const [];
    final services = ref.watch(
      servicesProvider((q: _query.isEmpty ? null : _query, categoryId: _categoryId, sort: null)),
    );

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
              controller: _controller,
              hintText: 'ابحث باسم الخدمة أو الفني…',
              leading: const Icon(Icons.search, color: SahelColors.primary600),
              backgroundColor: WidgetStateProperty.all(SahelColors.surface2),
              elevation: WidgetStateProperty.all(0),
              side: WidgetStateProperty.all(
                  const BorderSide(color: SahelColors.border)),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: SahelRadii.pillRadius),
              ),
              padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 16)),
              onChanged: _onQuery,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _categoryChip(label: 'الكل', selected: _categoryId == null,
                    onTap: () => setState(() => _categoryId = null)),
                for (final c in categories)
                  _categoryChip(
                    label: c.name,
                    selected: _categoryId == c.id,
                    onTap: () => setState(() => _categoryId = c.id),
                  ),
              ],
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
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _cityId,
                        hint: const Text('اختر المدينة'),
                        items: [
                          for (final c in cities)
                            DropdownMenuItem<int>(
                              value: toInt(c['id']),
                              child: Text(str(c['name'])),
                            ),
                        ],
                        onChanged: (v) => setState(() => _cityId = v),
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
                          style: TextStyle(
                              fontSize: 12, color: SahelColors.textMuted),
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
                          '${_priceRange.start.round()}',
                          '${_priceRange.end.round()}',
                        ),
                        onChanged: (v) => setState(() => _priceRange = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilterChip(
                  avatar: const Icon(Icons.star,
                      color: SahelColors.amber, size: 16),
                  label: const Text('4.5★ فأكثر'),
                  selected: _ratingFilter,
                  onSelected: (v) => setState(() => _ratingFilter = v),
                  selectedColor: SahelColors.amberSoft,
                  backgroundColor: SahelColors.surface2,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color:
                        _ratingFilter ? SahelColors.amber : SahelColors.text,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: SahelRadii.pillRadius),
                ),
              ],
            ),
            const SizedBox(height: 20),
            services.when(
              loading: () => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68,
                children: const [
                  ShimmerCard(height: 200),
                  ShimmerCard(height: 200),
                  ShimmerCard(height: 200),
                  ShimmerCard(height: 200),
                ],
              ),
              error: (e, _) => _ErrorBox(
                onRetry: () => ref.invalidate(servicesProvider(
                    (q: _query.isEmpty ? null : _query,
                        categoryId: _categoryId,
                        sort: null))),
              ),
              data: (raw) {
                var items = raw.cast<Service>();
                if (_ratingFilter) {
                  items =
                      items.where((s) => s.ratingAvg >= 4.5).toList();
                }
                items = items
                    .where((s) =>
                        s.basePrice >= _priceRange.start &&
                        s.basePrice <= _priceRange.end)
                    .toList();
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text(
                        'لا توجد نتائج مطابقة',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: SahelColors.textMuted,
                        ),
                      ),
                    ),
                  );
                }
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.68,
                  children: [
                    for (final s in items)
                      ServiceCard(
                        service: s,
                        onTap: () => context.push(
                            '/home/services/${s.slug.isNotEmpty ? s.slug : s.id}',
                            extra: s),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: selected ? Colors.white : SahelColors.text,
      ),
      selectedColor: SahelColors.primary600,
      backgroundColor: SahelColors.surface2,
      side: BorderSide(
          color: selected ? SahelColors.primary600 : SahelColors.border),
      shape: RoundedRectangleBorder(borderRadius: SahelRadii.pillRadius),
      onSelected: (_) => onTap(),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorBox({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.cloud_off_outlined,
                size: 48, color: SahelColors.textMuted),
            const SizedBox(height: 8),
            const Text(
              'تعذر تحميل النتائج',
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: SahelColors.textMuted),
            ),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
