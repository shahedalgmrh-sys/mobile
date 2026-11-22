import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/models/provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/empty_state.dart';
import 'package:saber_flutter/shared/widgets/favorite_toggle_button.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';

/// Public providers directory backed by `GET /providers` (verified providers
/// only) with optional city filter from `GET /cities`.
class ProvidersDirectoryScreen extends ConsumerStatefulWidget {
  const ProvidersDirectoryScreen({super.key});

  @override
  ConsumerState<ProvidersDirectoryScreen> createState() =>
      _ProvidersDirectoryScreenState();
}

class _ProvidersDirectoryScreenState
    extends ConsumerState<ProvidersDirectoryScreen> {
  final _searchController = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;
  String _query = '';
  String? _cityId;

  ProviderDirectoryFilters get _filters => (q: _query, cityId: _cityId);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() => _query = value.trim());
    });
  }

  void _selectCity(String? id) {
    if (_cityId == id) return;
    setState(() => _cityId = id);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    if (position.pixels < position.maxScrollExtent - 320) return;
    _loadMore();
  }

  Future<void> _loadMore() async {
    try {
      await ref
          .read(providerDirectoryProvider(_filters).notifier)
          .loadMore();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تحميل المزيد من المزودين')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(providerDirectoryProvider(_filters));

    return Scaffold(
      backgroundColor: SahelColors.bg,
      appBar: AppBar(title: const Text('دليل المزودين')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: _SearchField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onClear: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
              ),
            ),
            _CityFilter(
              selectedCityId: _cityId,
              onSelected: _selectCity,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: providers.when(
                loading: () => ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    ShimmerCard(height: 96, radius: 16),
                    SizedBox(height: 12),
                    ShimmerCard(height: 96, radius: 16),
                    SizedBox(height: 12),
                    ShimmerCard(height: 96, radius: 16),
                  ],
                ),
                error: (e, _) => _DirectoryError(
                  onRetry: () =>
                      ref.invalidate(providerDirectoryProvider(_filters)),
                ),
                data: (state) {
                  if (state.items.isEmpty) {
                    return EmptyState(
                      title: 'لا يوجد مزودون مطابقون',
                      subtitle: _cityId != null || _query.isNotEmpty
                          ? 'جرّب تغيير المدينة أو مصطلح البحث'
                          : 'سيظهر المزودون المعتمدون هنا بمجرد توفرهم',
                      icon: Icons.storefront_outlined,
                      ctaLabel: (_cityId != null || _query.isNotEmpty)
                          ? 'إعادة ضبط الفلاتر'
                          : null,
                      onCta: () {
                        _searchController.clear();
                        setState(() {
                          _query = '';
                          _cityId = null;
                        });
                      },
                    );
                  }
                  return RefreshIndicator(
                    color: SahelColors.primary,
                    onRefresh: () async => ref.invalidate(
                      providerDirectoryProvider(_filters),
                    ),
                    child: ListView.separated(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: state.items.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        if (index == state.items.length) {
                          return _PaginationFooter(
                            isLoadingMore: state.isLoadingMore,
                            hasMore: state.hasMore,
                            onLoadMore: _loadMore,
                          );
                        }
                        final provider = state.items[index];
                        return _ProviderDirectoryCard(provider: provider);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'ابحث باسم المزود أو وصف الخدمة…',
        prefixIcon: const Icon(Icons.search, color: SahelColors.textMuted),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, __) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close, size: 20),
                  tooltip: 'مسح البحث',
                ),
        ),
        filled: true,
        fillColor: SahelColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: const OutlineInputBorder(
          borderRadius: SahelRadii.pillRadius,
          borderSide: BorderSide(color: SahelColors.border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: SahelRadii.pillRadius,
          borderSide: BorderSide(color: SahelColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: SahelRadii.pillRadius,
          borderSide: BorderSide(color: SahelColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _CityFilter extends ConsumerWidget {
  const _CityFilter({
    required this.selectedCityId,
    required this.onSelected,
  });

  final String? selectedCityId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cities = ref.watch(citiesProvider);

    return cities.when(
      loading: () => const SizedBox(
        height: 48,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              ShimmerCard(width: 64, height: 32, radius: 16),
              SizedBox(width: 8),
              ShimmerCard(width: 80, height: 32, radius: 16),
              SizedBox(width: 8),
              ShimmerCard(width: 72, height: 32, radius: 16),
            ],
          ),
        ),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.location_off_outlined,
                size: 16, color: SahelColors.textMuted),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'تعذر تحميل المدن',
                style: TextStyle(fontSize: 12.5, color: SahelColors.textMuted),
              ),
            ),
            TextButton(
              onPressed: () => ref.invalidate(citiesProvider),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: items.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              if (index == 0) {
                return _CityChip(
                  label: 'كل المدن',
                  selected: selectedCityId == null,
                  onTap: () => onSelected(null),
                );
              }
              final city = items[index - 1];
              final id = str(city['id']);
              if (id.isEmpty) return const SizedBox.shrink();
              final label = str(city['name_ar'] ?? city['name'], 'مدينة');
              return _CityChip(
                label: label,
                selected: selectedCityId == id,
                onTap: () => onSelected(id),
              );
            },
          ),
        );
      },
    );
  }
}

class _CityChip extends StatelessWidget {
  const _CityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? SahelColors.primary : SahelColors.surface,
      borderRadius: SahelRadii.pillRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: SahelRadii.pillRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: SahelRadii.pillRadius,
            border: Border.all(
              color: selected ? SahelColors.primary : SahelColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? SahelColors.onPrimary : SahelColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProviderDirectoryCard extends StatelessWidget {
  const _ProviderDirectoryCard({required this.provider});

  final ProviderModel provider;

  @override
  Widget build(BuildContext context) {
    final name = str(provider.businessName, 'مزود خدمة');
    final city = provider.city == null || str(provider.city).isEmpty
        ? null
        : str(provider.city);
    final logo = provider.avatarUrl == null || str(provider.avatarUrl).isEmpty
        ? null
        : str(provider.avatarUrl);
    final hasRating = provider.totalReviews > 0;

    return Material(
      color: SahelColors.surface,
      borderRadius: SahelRadii.mdRadius,
      child: InkWell(
        borderRadius: SahelRadii.mdRadius,
        onTap: () => context.push('/home/providers/${provider.id}'),
        child: Ink(
          decoration: BoxDecoration(
            color: SahelColors.surface,
            borderRadius: SahelRadii.mdRadius,
            border: Border.all(color: SahelColors.border),
            boxShadow: SahelElevations.xs,
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProviderAvatar(logo: logo, name: name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: SahelTextStyles.titleCard,
                          ),
                        ),
                        if (provider.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified,
                              size: 16, color: SahelColors.primary),
                        ],
                      ],
                    ),
                    if (city != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: SahelColors.textMuted),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              city,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: SahelTextStyles.caption,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (hasRating)
                          _MetaPill(
                            icon: Icons.star,
                            iconColor: SahelColors.amber500,
                            label:
                                '${provider.ratingAvg.toStringAsFixed(1)} (${provider.totalReviews})',
                          ),
                        _MetaPill(
                          icon: Icons.home_repair_service,
                          iconColor: SahelColors.primary600,
                          label: '${provider.servicesCount} خدمة',
                        ),
                        _MetaPill(
                          icon: Icons.check_circle_outline,
                          iconColor: SahelColors.primary600,
                          label: '${provider.completedBookings} حجز منجز',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              FavoriteToggleButton(
                id: provider.id,
                isProvider: true,
                size: 36,
              ),
              const Icon(Icons.chevron_left, color: SahelColors.textSoft),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderAvatar extends StatelessWidget {
  const _ProviderAvatar({required this.logo, required this.name});

  final String? logo;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: const BoxDecoration(
        color: SahelColors.primarySurface,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: logo != null
          ? CachedNetworkImage(
              imageUrl: logo!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _initial(),
              placeholder: (_, __) => _initial(),
            )
          : _initial(),
    );
  }

  Widget _initial() => Center(
        child: Text(
          name.isNotEmpty ? name.substring(0, 1) : 'م',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: SahelColors.primary,
          ),
        ),
      );
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: const BoxDecoration(
        color: SahelColors.surfaceSubtle,
        borderRadius: SahelRadii.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: SahelColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.isLoadingMore,
    required this.hasMore,
    required this.onLoadMore,
  });

  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (!hasMore) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
}

class _DirectoryError extends StatelessWidget {
  const _DirectoryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined,
              size: 56, color: SahelColors.textMuted),
          const SizedBox(height: 12),
          const Text(
            'تعذر تحميل المزودين',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: SahelColors.textMuted),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
