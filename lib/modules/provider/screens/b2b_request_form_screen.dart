import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/core/errors/failures.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/data/sources/remote_sources.dart';
import 'package:saber_flutter/models/provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/shimmer_card.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';

/// Provider-to-provider (B2B) request — mirrors `POST /provider/requests`.
///
/// Required by the API: target_provider_id, service_id, city_id,
/// address_line, scheduled_date (today or later), scheduled_time, description.
/// `area_id` is optional.
class B2bRequestFormScreen extends ConsumerStatefulWidget {
  const B2bRequestFormScreen({super.key});

  @override
  ConsumerState<B2bRequestFormScreen> createState() =>
      _B2bRequestFormScreenState();
}

class _B2bRequestFormScreenState extends ConsumerState<B2bRequestFormScreen> {
  final _searchController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  String _query = '';
  Map<String, dynamic>? _target;
  String? _serviceId;
  String? _cityId;
  String? _areaId;
  DateTime? _date;
  TimeOfDay? _time;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref
          .read(providerDirectoryProvider((q: _query, cityId: null)).notifier)
          .loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_target == null ? 'اختيار مزوّد' : 'طلب تعاون جديد'),
        actions: [
          if (_target != null)
            TextButton(
              onPressed: () => setState(() {
                _target = null;
                _serviceId = null;
                _cityId = null;
                _areaId = null;
                _date = null;
                _time = null;
                _addressController.clear();
                _descriptionController.clear();
              }),
              child: const Text('تغيير المزوّد'),
            ),
        ],
      ),
      body: SafeArea(
        child: _target == null ? _buildProviderPicker() : _buildForm(),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Step 1 — pick the target provider from the public directory.
  // -------------------------------------------------------------------------

  Widget _buildProviderPicker() {
    final directory = ref.watch(
      providerDirectoryProvider((q: _query, cityId: null)),
    );
    final ownProfile = providerProfileFields(
      ref.watch(providerProfileProvider).valueOrNull,
    );
    final ownId = str(ownProfile['id']);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'ابحث باسم النشاط',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: directory.when(
            loading: () => ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                ShimmerCard(height: 86),
                SizedBox(height: 10),
                ShimmerCard(height: 86),
              ],
            ),
            error: (e, _) => Center(
              child: TextButton.icon(
                onPressed: () => ref.invalidate(
                  providerDirectoryProvider((q: _query, cityId: null)),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ),
            data: (state) {
              final items = state.items
                  .where((p) => ownId.isEmpty || p.id != ownId)
                  .toList();
              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    'لا يوجد مزوّدون مطابقون',
                    style: TextStyle(
                      color: SahelColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(
                  providerDirectoryProvider((q: _query, cityId: null)),
                ),
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length + (state.hasMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    if (index >= items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    final p = items[index];
                    return _providerTile(p);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _providerTile(ProviderModel provider) {
    final rating = provider.ratingAvg;
    final reviews = provider.totalReviews;
    return Material(
      color: SahelColors.onPrimary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(
          () => _target = {
            'id': provider.id,
            'business_name': provider.businessName,
          },
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SahelColors.slate200),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: SahelColors.primary100,
                child: Text(
                  provider.businessName.isNotEmpty
                      ? provider.businessName[0]
                      : 'م',
                  style: const TextStyle(
                    color: SahelColors.primary700,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.businessName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if ((provider.city ?? '').isNotEmpty) provider.city,
                        if (reviews > 0)
                          '★ ${rating.toStringAsFixed(1)} ($reviews)',
                      ].join(' · '),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: SahelColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: SahelColors.muted),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Step 2 — request details.
  // -------------------------------------------------------------------------

  Widget _buildForm() {
    final targetId = str(_target?['id']);
    final profile = ref.watch(publicProviderProfileProvider(targetId));
    final cities = ref.watch(citiesProvider);

    return profile.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ShimmerCard(height: 90),
          SizedBox(height: 12),
          ShimmerCard(height: 260),
        ],
      ),
      error: (e, _) => Center(
        child: TextButton.icon(
          onPressed: () =>
              ref.invalidate(publicProviderProfileProvider(targetId)),
          icon: const Icon(Icons.refresh),
          label: const Text('إعادة المحاولة'),
        ),
      ),
      data: (data) {
        final provider = asMap(data['provider']);
        final services = dataList(data['services'])
            .where(
              (s) =>
                  toBool(s['is_active'], true) &&
                  toBool(s['is_available'], true),
            )
            .toList();
        final name = str(
          provider['business_name'] ?? _target?['business_name'],
          'مزوّد',
        );

        if (services.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 48,
                    color: SahelColors.muted,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'لا توجد خدمات متاحة للحجز لدى $name حالياً.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: SahelColors.muted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => setState(() => _target = null),
                    child: const Text('اختيار مزوّد آخر'),
                  ),
                ],
              ),
            ),
          );
        }

        var serviceStillExists = false;
        for (final service in services) {
          if (str(service['id']) == _serviceId) {
            serviceStillExists = true;
            break;
          }
        }
        final effectiveServiceId = serviceStillExists ? _serviceId : null;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SahelColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.storefront_outlined,
                    color: SahelColors.primary700,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey('service-$effectiveServiceId'),
              initialValue: effectiveServiceId,
              decoration: const InputDecoration(labelText: 'الخدمة *'),
              items: [
                for (final service in services)
                  DropdownMenuItem(
                    value: str(service['id']),
                    child: Text(
                      [
                        str(service['name'], 'خدمة'),
                        if (str(service['formatted_price']).isNotEmpty)
                          str(service['formatted_price']),
                      ].join(' · '),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _serviceId = v),
            ),
            const SizedBox(height: 12),
            cities.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => const Text('تعذر تحميل المدن'),
              data: (items) => DropdownButtonFormField<String>(
                key: ValueKey('city-$_cityId'),
                initialValue: _cityId,
                decoration: const InputDecoration(labelText: 'المدينة *'),
                items: [
                  for (final city in items)
                    DropdownMenuItem(
                      value: str(city['id']),
                      child: Text(str(city['name'])),
                    ),
                ],
                onChanged: (v) => setState(() {
                  _cityId = v;
                  _areaId = null;
                }),
              ),
            ),
            const SizedBox(height: 12),
            if (_cityId != null)
              ref
                  .watch(providerCityAreasProvider(_cityId!))
                  .when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => const Text('تعذر تحميل المناطق'),
                    data: (areas) => DropdownButtonFormField<String>(
                      key: ValueKey('area-$_areaId'),
                      initialValue: _areaId,
                      decoration: const InputDecoration(
                        labelText: 'المنطقة (اختياري)',
                      ),
                      items: [
                        for (final area in areas)
                          DropdownMenuItem(
                            value: str(area['id']),
                            child: Text(str(area['name'])),
                          ),
                      ],
                      onChanged: (v) => setState(() => _areaId = v),
                    ),
                  ),
            if (_cityId != null) const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              maxLength: 255,
              decoration: const InputDecoration(
                labelText: 'العنوان التفصيلي *',
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event_outlined, size: 18),
                    label: Text(
                      _date == null ? 'تاريخ التنفيذ *' : _formatDate(_date!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.schedule, size: 18),
                    label: Text(
                      _time == null ? 'الوقت *' : _formatTime(_time!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 1000,
              decoration: const InputDecoration(
                labelText: 'وصف الطلب *',
                hintText: 'اشرح الخدمة المطلوبة من المزوّد',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('إرسال الطلب'),
            ),
            const SizedBox(height: 8),
            const Text(
              'سيُرسل الطلب إلى المزوّد المختار كطلب تعاون (B2B) '
              'ويظهر في «الصادرة» لدى مزوّدك.',
              style: TextStyle(
                fontSize: 11,
                color: SahelColors.muted,
                height: 1.5,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'تاريخ تنفيذ الطلب',
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => _time = picked);
  }

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    final targetId = str(_target?['id']);
    final address = _addressController.text.trim();
    final description = _descriptionController.text.trim();

    String? missing;
    if (_serviceId == null) {
      missing = 'اختر الخدمة';
    } else if (_cityId == null) {
      missing = 'اختر المدينة';
    } else if (address.isEmpty) {
      missing = 'أدخل العنوان التفصيلي';
    } else if (_date == null) {
      missing = 'اختر تاريخ التنفيذ';
    } else if (_time == null) {
      missing = 'اختر وقت التنفيذ';
    } else if (description.isEmpty) {
      missing = 'أدخل وصف الطلب';
    }
    if (missing != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(missing)));
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(providerRepositoryProvider).storeServiceRequest({
        'target_provider_id': targetId,
        'service_id': _serviceId,
        'city_id': _cityId,
        if (_areaId != null) 'area_id': _areaId,
        'address_line': address,
        'scheduled_date': _formatDate(_date!),
        'scheduled_time': _formatTime(_time!),
        'description': description,
      });
      ref.invalidate(serviceRequestsProvider('outgoing'));
      ref.invalidate(serviceRequestsProvider('incoming'));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('تم إرسال طلب التعاون ✓')));
      Navigator.pop(context);
    } catch (error) {
      String message = 'تعذر إرسال الطلب';
      if (error is ApiException) {
        final failure = error.failure;
        if (failure is ServerFailure && failure.message.isNotEmpty) {
          message = failure.message;
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(message), backgroundColor: SahelColors.danger),
        );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
