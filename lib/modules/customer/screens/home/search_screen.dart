import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/data/repositories/catalog_repository.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/models/service.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/providers/location_provider.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/service_card.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({
    super.key,
    this.initialCategory,
    this.initialNearby = false,
  });

  final String? initialCategory;
  final bool initialNearby;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;
  String _query = '';
  String? _categoryId;
  RangeValues _priceRange = const RangeValues(0, 20000);
  bool _ratingFilter = false;
  String? _cityId;
  String _sort = 'relevance';
  bool _nearbyEnabled = false;
  double _radiusKm = 10;
  bool _requestingLocation = false;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initialCategory;
    _scroll.addListener(_onScroll);
    if (widget.initialNearby) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _enableNearby(forceRefresh: true);
      });
    }
  }

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategory != widget.initialCategory) {
      setState(() => _categoryId = widget.initialCategory);
    }
    if (oldWidget.initialNearby != widget.initialNearby && widget.initialNearby) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _enableNearby(forceRefresh: true);
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Current filter set. It doubles as the family key of
  /// [customerSearchProvider], so changing any filter reloads page 1.
  CustomerSearchFilters get _searchParams => (
    q: _query,
    categoryId: _categoryId,
    cityId: _nearbyEnabled ? null : _cityId,
    minPrice: _priceRange.start,
    maxPrice: _priceRange.end,
    minRating: _ratingFilter ? 4.5 : null,
    latitude:
        _nearbyEnabled ? ref.read(appLocationProvider).valueOrNull?.latitude : null,
    longitude:
        _nearbyEnabled ? ref.read(appLocationProvider).valueOrNull?.longitude : null,
    radiusKm: _nearbyEnabled ? _radiusKm : null,
    sort: _nearbyEnabled ? 'nearest' : _sort,
  );

  /// Prefetches the next page once the list comes within ~320px of the end.
  void _onScroll() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    if (position.pixels < position.maxScrollExtent - 320) return;
    _loadMore();
  }

  Future<void> _loadMore() async {
    try {
      await ref.read(customerSearchProvider(_searchParams).notifier).loadMore();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تحميل المزيد من النتائج')),
      );
    }
  }

  void _onQuery(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      setState(() => _query = v.trim());
    });
  }

  void _resetFilters() {
    setState(() {
      _query = '';
      _controller.clear();
      _categoryId = widget.initialCategory;
      _priceRange = const RangeValues(0, 20000);
      _ratingFilter = false;
      _cityId = null;
      _sort = 'relevance';
      _nearbyEnabled = false;
      _radiusKm = 10;
    });
  }

  Future<void> _enableNearby({bool forceRefresh = false}) async {
    if (_requestingLocation) return;
    setState(() => _requestingLocation = true);

    try {
      final location = await ref
          .read(appLocationProvider.notifier)
          .useCurrentLocation(forceRefresh: forceRefresh);

      if (!mounted) return;
      setState(() {
        _nearbyEnabled = location != null;
        if (_nearbyEnabled) {
          _cityId = null;
        }
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _requestingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const [];
    final cities = ref.watch(citiesProvider).valueOrNull ?? const [];
    final services = ref.watch(customerSearchProvider(_searchParams));
    final total = services.valueOrNull?.total;
    final location = ref.watch(appLocationProvider);
    final currentLocation = location.valueOrNull;

    return Scaffold(
      backgroundColor: SahelColors.bg,
      appBar: AppBar(
        title: const Text(
          'البحث والتصفية',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: ListView(
        controller: _scroll,
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SahelColors.surface,
              borderRadius: SahelRadii.mdRadius,
              border: Border.all(color: SahelColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBar(
                  controller: _controller,
                  hintText: 'ابحث باسم الخدمة أو الفني…',
                  leading: const Icon(
                    Icons.search,
                    color: SahelColors.primary600,
                  ),
                  backgroundColor: WidgetStateProperty.all(
                    SahelColors.surface2,
                  ),
                  elevation: WidgetStateProperty.all(0),
                  side: WidgetStateProperty.all(
                    const BorderSide(color: SahelColors.border),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(borderRadius: SahelRadii.pillRadius),
                  ),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: _onQuery,
                ),
                const SizedBox(height: 16),
                const _FilterSectionTitle('الأقسام'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _categoryChip(
                      label: 'الكل',
                      selected: _categoryId == null,
                      onTap: () => setState(() => _categoryId = null),
                    ),
                    for (final c in categories)
                      _categoryChip(
                        label: c.name,
                        selected: _categoryId == c.id,
                        onTap: () => setState(() => _categoryId = c.id),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const _FilterSectionTitle('المدينة'),
                InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _cityId,
                      hint: const Text('كل المدن'),
                      disabledHint: const Text('تم تعطيل اختيار المدينة أثناء البحث القريب'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('كل المدن'),
                        ),
                        for (final c in cities)
                          DropdownMenuItem<String>(
                            value: str(c['id']),
                            child: Text(
                              str(c['name']),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: _nearbyEnabled
                          ? null
                          : (v) => setState(
                                () => _cityId =
                                    (v == null || v.isEmpty) ? null : v,
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const _FilterSectionTitle('الموقع الحالي'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _nearbyEnabled
                        ? SahelColors.primarySurface
                        : SahelColors.surface2,
                    borderRadius: SahelRadii.mdRadius,
                    border: Border.all(
                      color: _nearbyEnabled
                          ? SahelColors.primary200
                          : SahelColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: FilterChip(
                              selected: _nearbyEnabled,
                              onSelected: (selected) async {
                                if (!selected) {
                                  setState(() => _nearbyEnabled = false);
                                  return;
                                }
                                await _enableNearby(forceRefresh: true);
                              },
                              avatar: const Icon(
                                Icons.my_location,
                                size: 16,
                                color: SahelColors.primary,
                              ),
                              label: Text(
                                _requestingLocation
                                    ? 'جارٍ تحديد موقعك...'
                                    : 'بالقرب مني',
                              ),
                              selectedColor: SahelColors.primarySurface,
                              backgroundColor: SahelColors.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: SahelRadii.pillRadius,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: _requestingLocation
                                ? null
                                : () => _enableNearby(forceRefresh: true),
                            icon: const Icon(Icons.gps_fixed),
                            label: const Text('تحديث'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentLocation == null
                            ? 'استخدمي موقعك الحالي لترتيب الخدمات من الأقرب إلى الأبعد.'
                            : 'الموقع: ${currentLocation.city ?? 'تم تحديد الإحداثيات'}'
                                ' • الدقة ${currentLocation.accuracy.toStringAsFixed(0)}م'
                                ' • المصدر: ${currentLocation.source}',
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: SahelColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final radius in [5.0, 10.0, 25.0, 50.0])
                            ChoiceChip(
                              label: Text('${radius.toInt()} كم'),
                              selected: _radiusKm == radius,
                              onSelected: _nearbyEnabled
                                  ? (_) => setState(() => _radiusKm = radius)
                                  : null,
                              selectedColor: SahelColors.primary600,
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _radiusKm == radius
                                    ? Colors.white
                                    : SahelColors.text,
                              ),
                              backgroundColor: SahelColors.surface,
                              side: BorderSide(
                                color: _radiusKm == radius
                                    ? SahelColors.primary600
                                    : SahelColors.border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: SahelRadii.pillRadius,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const _FilterSectionTitle('الترتيب'),
                if (_nearbyEnabled)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SahelColors.primarySurface,
                      borderRadius: SahelRadii.mdRadius,
                    ),
                    child: const Text(
                      'أثناء تفعيل "بالقرب مني" يتم ترتيب النتائج تلقائيًا من الأقرب إلى الأبعد.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: SahelColors.primary700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _sortChip('الأكثر صلة', 'relevance'),
                      _sortChip('الأعلى تقييماً', 'rating'),
                      _sortChip('الأقل سعراً', 'price_low'),
                      _sortChip('الأعلى سعراً', 'price_high'),
                      _sortChip('الأكثر طلباً', 'popular'),
                    ],
                  ),
                const SizedBox(height: 16),
                const _FilterSectionTitle('الجودة'),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilterChip(
                    avatar: const Icon(
                      Icons.star,
                      color: SahelColors.amber,
                      size: 16,
                    ),
                    label: const Text('4.5★ فأكثر'),
                    selected: _ratingFilter,
                    onSelected: (v) => setState(() => _ratingFilter = v),
                    selectedColor: SahelColors.amberSoft,
                    backgroundColor: SahelColors.surface2,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _ratingFilter
                          ? SahelColors.amber800
                          : SahelColors.text,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: SahelRadii.pillRadius,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const _FilterSectionTitle('نطاق السعر'),
                Row(
                  children: [
                    _PriceBadge(
                      value: _priceRange.start.round(),
                      alignStart: true,
                    ),
                    const Spacer(),
                    _PriceBadge(
                      value: _priceRange.end.round(),
                      alignStart: false,
                    ),
                  ],
                ),
                RangeSlider(
                  min: 0,
                  max: 20000,
                  divisions: 40,
                  values: _priceRange,
                  activeColor: SahelColors.primary600,
                  inactiveColor: SahelColors.surface3,
                  labels: RangeLabels(
                    '${_priceRange.start.round()}',
                    '${_priceRange.end.round()}',
                  ),
                  onChanged: (v) => setState(() => _priceRange = v),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _resetFilters,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('إعادة ضبط الفلاتر'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              total == null ? 'النتائج' : 'النتائج ($total)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: SahelColors.text,
              ),
            ),
          ),
          const SizedBox(height: 12),
          services.when(
            loading: () => _SearchGridSkeleton(),
            error: (e, _) => _ErrorBox(
              onRetry: () =>
                  ref.invalidate(customerSearchProvider(_searchParams)),
            ),
            data: (state) {
              final items = state.items.map((json) {
                final provider = asMap(json['provider']);
                final category = asMap(json['category']);
                final service = serviceFromJson(json);
                return _SearchCardData(
                  service: service,
                  providerName: strOrNull(provider['business_name']),
                  categoryLabel: strOrNull(category['name']),
                  distanceKm: service.distanceKm,
                );
              }).toList();
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = width >= 760 ? 3 : 2;
                      final cardHeight = _resultCardHeight(width);
                      return GridView.builder(
                        itemCount: items.length,
                        shrinkWrap: true,
                        primary: false,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: cardHeight,
                        ),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final s = item.service;
                          return ServiceCard(
                            service: s,
                            providerName: item.providerName,
                            categoryLabel: item.categoryLabel,
                            specLabel: item.distanceKm == null
                                ? null
                                : '${item.distanceKm!.toStringAsFixed(1)} كم',
                            onTap: () => context.push(
                              '/home/services/${s.slug.isNotEmpty ? s.slug : s.id}',
                              extra: s,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  _PaginationFooter(
                    isLoadingMore: state.isLoadingMore,
                    hasMore: state.hasMore,
                    showEndOfList: state.lastPage > 1,
                    onLoadMore: _loadMore,
                  ),
                ],
              );
            },
          ),
        ],
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
        color: selected ? SahelColors.primary600 : SahelColors.border,
      ),
      shape: RoundedRectangleBorder(borderRadius: SahelRadii.pillRadius),
      onSelected: (_) => onTap(),
    );
  }

  Widget _sortChip(String label, String value) {
    final selected = _sort == value;
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
        color: selected ? SahelColors.primary600 : SahelColors.border,
      ),
      shape: RoundedRectangleBorder(borderRadius: SahelRadii.pillRadius),
      onSelected: (_) => setState(() => _sort = value),
    );
  }
}

class _SearchCardData {
  const _SearchCardData({
    required this.service,
    this.providerName,
    this.categoryLabel,
    this.distanceKm,
  });

  final Service service;
  final String? providerName;
  final String? categoryLabel;
  final double? distanceKm;
}

class _FilterSectionTitle extends StatelessWidget {
  const _FilterSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: SahelColors.text,
        ),
      ),
    );
  }
}

class _PriceBadge extends StatelessWidget {
  const _PriceBadge({required this.value, required this.alignStart});

  final int value;
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: SahelColors.surface2,
        borderRadius: SahelRadii.mdRadius,
        border: Border.all(color: SahelColors.border),
      ),
      child: Text(
        '${alignStart ? 'من' : 'إلى'} $value',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: SahelColors.text,
        ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.isLoadingMore,
    required this.hasMore,
    required this.showEndOfList,
    required this.onLoadMore,
  });

  final bool isLoadingMore;
  final bool hasMore;
  final bool showEndOfList;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: isLoadingMore
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : TextButton.icon(
                  onPressed: onLoadMore,
                  icon: const Icon(Icons.expand_more),
                  label: const Text('تحميل المزيد'),
                ),
        ),
      );
    }

    if (!showEndOfList) return const SizedBox.shrink();

    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          'تم عرض جميع النتائج',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: SahelColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _SearchGridSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 760 ? 3 : 2;
        final height = _resultCardHeight(width);
        return GridView.builder(
          itemCount: 4,
          shrinkWrap: true,
          primary: false,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: height,
          ),
          itemBuilder: (_, __) => ShimmerCard(height: height),
        );
      },
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
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: SahelColors.textMuted,
            ),
            const SizedBox(height: 8),
            const Text(
              'تعذر تحميل النتائج',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: SahelColors.textMuted,
              ),
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

/// Height of a search-result grid cell. The card's media block (176) plus the
/// pricing ribbon need roughly 430px; the extra room lets a two-line Arabic
/// title render in full before [ServiceCard] starts trimming it.
double _resultCardHeight(double width) => width < 380 ? 458 : 440;
