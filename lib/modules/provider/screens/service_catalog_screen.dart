import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';
import '../../../shared/theme/sahel_colors.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';

class ServiceCatalogScreen extends ConsumerWidget {
  const ServiceCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(providerServicesProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: SahelColors.primary600,
        foregroundColor: Colors.white,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(title: const Text('كتالوج الخدمات')),
      body: SafeArea(
        child: services.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ShimmerCard(height: 150),
              SizedBox(height: 12),
              ShimmerCard(height: 150),
            ],
          ),
          error: (e, _) => Center(
            child: TextButton.icon(
              onPressed: () => ref.invalidate(providerServicesProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ),
          data: (items) => RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(providerServicesProvider),
            child: items.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text('لا توجد خدمات بعد — أضف أول خدمة',
                            style: TextStyle(
                                color: SahelColors.muted,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (_, i) =>
                        _ServiceCard(service: items[i]),
                  ),
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> service;
  const _ServiceCard({required this.service});

  @override
  ConsumerState<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends ConsumerState<_ServiceCard> {
  late bool _active = toBool(widget.service['is_active'] ??
      widget.service['is_available'],
      true);
  bool _busy = false;

  Future<void> _toggle() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(providerRepositoryProvider)
          .toggleService(toInt(widget.service['id']));
      setState(() => _active = !_active);
      ref.invalidate(providerServicesProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر تحديث الحالة')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    final title = str(s['name'] ?? s['title'], 'خدمة');
    final desc = str(s['description'] ?? s['short_description']);
    final price =
        str(s['formatted_price'] ?? s['display_price'] ?? s['price']);
    final rating = toDouble(s['average_rating'] ?? s['rating']);
    final reviews = toInt(s['reviews_count'] ?? s['review_count']);

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
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16)),
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(desc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: SahelColors.muted,
                              fontSize: 12,
                              height: 1.4)),
                    ],
                  ],
                ),
              ),
              _busy
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Switch(
                      value: _active,
                      onChanged: (_) => _toggle(),
                      activeTrackColor: SahelColors.primary200,
                      activeThumbColor: SahelColors.primary600,
                    ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star,
                  size: 14, color: SahelColors.amber500),
              const SizedBox(width: 2),
              Text(
                  '${rating.toStringAsFixed(1)} ($reviews)',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(price,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: SahelColors.primary700,
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: SahelButton.soft(
                      label: 'تعديل',
                      onTap: () {},
                      height: 36,
                      width: 0)),
              const SizedBox(width: 8),
              Expanded(
                  child: SahelButton(
                      label: 'الحجوزات',
                      variant: SahelButtonVariant.outline,
                      onPressed: () {},
                      height: 36,
                      width: 0)),
            ],
          ),
        ],
      ),
    );
  }
}
