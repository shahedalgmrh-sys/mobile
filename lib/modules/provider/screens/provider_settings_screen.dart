import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/providers/settings_provider.dart';
import '../../../shared/theme/sahel_colors.dart';

final providerCityAreasProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>(
  (ref, cityId) => ref.watch(catalogRepositoryProvider).cityAreas(cityId),
);

class ProviderSettingsScreen extends ConsumerWidget {
  const ProviderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final profile = ref.watch(providerProfileProvider).valueOrNull;
    final user = auth.user ?? const <String, dynamic>{};
    final businessName = str(
        profile?['business_name'] ?? user['name'], 'مزود ساحل');
    final contact = str(user['phone'] ?? user['email']);
    final isVerified = toBool(
        profile?['is_verified'] ??
            (str(profile?['verification_status']) == 'verified'));
    final language = ref.watch(appSettingsProvider).language;

    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الحساب')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: SahelColors.primaryGradient,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              accountName: Text(businessName,
                  style:
                      const TextStyle(fontWeight: FontWeight.w700)),
              accountEmail: Text(
                  '$contact${isVerified ? ' · موثق' : ''}'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                    businessName.isNotEmpty ? businessName[0] : 'س',
                    style: const TextStyle(
                        color: SahelColors.primary700,
                        fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 16),
            _g('الملف التجاري', [
              _t(Icons.badge_outlined, 'المعلومات الأساسية',
                  () => context.push('/p/settings/basic')),
              _t(Icons.rate_review_outlined, 'مراجعاتي والردود',
                  () => context.push('/p/reviews')),
              _t(Icons.verified_user_outlined, 'التحقق (KYC)',
                  () => context.push('/p/kyc')),
              _t(Icons.photo_library_outlined, 'صور الأعمال',
                  () => context.push('/p/settings/portfolio')),
              _t(Icons.add_a_photo_outlined, 'صور النشاط (شعار/غلاف)',
                  () => _manageImages(context, ref)),
              _t(Icons.category_outlined, 'تصنيفات الخدمات',
                  () => context.push('/p/services')),
            ]),
            _g('العمليات', [
              _t(Icons.event_available_outlined, 'ساعات العمل',
                  () => context.push('/p/calendar')),
              _t(Icons.swap_horiz_outlined, 'طلباتي (تعاون المزوّدين)',
                  () => context.push('/p/service-requests')),
              _t(Icons.notifications_active_outlined,
                  'إشعارات الطلبات',
                  () => context.push('/p/notifications')),
              _t(Icons.location_on_outlined, 'مناطق الخدمة',
                  () => context.push('/p/settings/areas')),
              _t(Icons.account_balance_wallet_outlined, 'السحوبات',
                  () => context.push('/p/withdraw')),
            ]),
            _g('التطبيق', [
              _t(
                Icons.translate_outlined,
                'اللغة',
                () => context.push('/settings/language'),
                subtitle: language == 'en' ? 'English' : 'العربية',
              ),
            ]),
            _g('الأمان', [
              _t(Icons.lock_outline, 'تغيير كلمة المرور',
                  () => _changePassword(context, ref)),
            ]),
            _g('الحساب', [
              _t(Icons.logout_outlined, 'تسجيل الخروج', () async {
                await ref
                    .read(authNotifierProvider.notifier)
                    .logout();
              }),
            ]),
          ],
        ),
      ),
    );
  }

  /// Mirrors the customer settings flow against `/provider/profile/password`.
  Future<void> _changePassword(
      BuildContext context, WidgetRef ref) async {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: current,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'كلمة المرور الحالية')),
            const SizedBox(height: 12),
            TextField(
                controller: next,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'كلمة المرور الجديدة')),
            const SizedBox(height: 12),
            TextField(
                controller: confirm,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'تأكيد كلمة المرور')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حفظ')),
        ],
      ),
    );
    if (ok != true) return;
    if (next.text != confirm.text || next.text.length < 8) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('كلمة المرور يجب أن تكون 8 أحرف على الأقل ومتطابقة')));
      }
      return;
    }
    try {
      await ref
          .read(providerRepositoryProvider)
          .changePassword(current.text, next.text, confirm.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تم تغيير كلمة المرور بنجاح')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('تعذر تغيير كلمة المرور — تحقق من الحالية')));
      }
    }
  }

  /// Mirrors the server contract: multipart `POST /provider/profile/logo`
  /// (jpeg/png ≤4MB) and DELETE endpoints for avatar/logo/cover.
  Future<void> _manageImages(BuildContext context, WidgetRef ref) async {
    void snack(String m, {bool error = false}) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(m), backgroundColor: error ? SahelColors.danger : null));
    }

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text('صور النشاط',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('تغيير شعار النشاط'),
              subtitle: const Text('JPG أو PNG حتى 4MB',
                  style: TextStyle(fontSize: 11, color: SahelColors.muted)),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 88,
                  maxWidth: 1200,
                );
                if (picked == null) return;
                snack('جاري رفع الشعار…');
                try {
                  await ref
                      .read(providerRepositoryProvider)
                      .updateLogo(picked.path);
                  ref.invalidate(providerProfileProvider);
                  snack('تم تحديث الشعار ✓');
                } catch (_) {
                  snack('تعذر رفع الشعار — تأكد أنه JPG/PNG ≤4MB', error: true);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.crop_free_outlined),
              title: const Text('حذف صورة الغلاف'),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  await ref
                      .read(providerRepositoryProvider)
                      .deleteProviderImage('cover');
                  ref.invalidate(providerProfileProvider);
                  snack('تم حذف الغلاف ✓');
                } catch (_) {
                  snack('تعذر حذف الغلاف', error: true);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_remove_outlined,
                  color: SahelColors.danger),
              title: const Text('حذف الصورة الرمزية',
                  style: TextStyle(color: SahelColors.danger)),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  await ref
                      .read(providerRepositoryProvider)
                      .deleteProviderImage('avatar');
                  await ref.read(authNotifierProvider.notifier).refreshUser();
                  snack('تم حذف الصورة الرمزية ✓');
                } catch (_) {
                  snack('تعذر حذف الصورة الرمزية', error: true);
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _g(String t, List<Widget> c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
          child: Text(t,
              style: const TextStyle(
                  fontSize: 12,
                  color: SahelColors.muted,
                  fontWeight: FontWeight.w700)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: SahelColors.slate200),
          ),
          child: Column(children: c),
        ),
      ],
    );
  }

  Widget _t(IconData i, String l, VoidCallback onTap, {String? subtitle}) {
    return ListTile(
      leading: Icon(i, color: SahelColors.primary600),
      title: Text(l, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: const TextStyle(
                color: SahelColors.muted,
                fontSize: 12,
              ),
            ),
      trailing:
          const Icon(Icons.chevron_right, color: SahelColors.muted),
      onTap: onTap,
      shape: const Border(
          bottom: BorderSide(color: SahelColors.slate100, width: 1)),
    );
  }
}

class ProviderProfileBasicsScreen extends ConsumerStatefulWidget {
  const ProviderProfileBasicsScreen({super.key});

  @override
  ConsumerState<ProviderProfileBasicsScreen> createState() =>
      _ProviderProfileBasicsScreenState();
}

class _ProviderProfileBasicsScreenState
    extends ConsumerState<ProviderProfileBasicsScreen> {
  final _businessNameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(providerProfileProvider);
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('المعلومات الأساسية')),
      body: SafeArea(
        child: profile.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: TextButton.icon(
              onPressed: () => ref.invalidate(providerProfileProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ),
          data: (data) {
            if (!_initialized) {
              _initialized = true;
              _businessNameController.text = str(
                data['business_name'] ?? auth.user?['name'],
              );
              _bioController.text = str(
                data['business_description'] ?? data['bio'],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'حدّث بيانات الملف التجاري التي تظهر للعملاء.',
                        style: TextStyle(
                          color: SahelColors.muted,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _businessNameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم النشاط',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _bioController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'نبذة تعريفية',
                          hintText: 'اكتب وصفًا مختصرًا عن نشاطك والخدمات التي تقدمها',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'رقم التواصل',
                          hintText: str(auth.user?['phone'] ?? auth.user?['email']),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('حفظ التعديلات'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _save() async {
    final businessName = _businessNameController.text.trim();
    final bio = _bioController.text.trim();
    if (businessName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل اسم النشاط أولاً')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(providerRepositoryProvider).updateProfile({
        'business_name': businessName,
        'business_description': bio,
      });
      ref.invalidate(providerProfileProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ المعلومات الأساسية')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حفظ البيانات الآن')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class ProviderServiceAreasScreen extends ConsumerStatefulWidget {
  const ProviderServiceAreasScreen({super.key});

  @override
  ConsumerState<ProviderServiceAreasScreen> createState() =>
      _ProviderServiceAreasScreenState();
}

class _ProviderServiceAreasScreenState
    extends ConsumerState<ProviderServiceAreasScreen> {
  String? _cityId;
  String? _areaId;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final cities = ref.watch(citiesProvider);
    final availability = ref.watch(providerAvailabilityProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('مناطق الخدمة')),
      body: SafeArea(
        child: availability.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: TextButton.icon(
              onPressed: () => ref.invalidate(providerAvailabilityProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ),
          data: (data) {
            final currentAreas = dataList(
              data['areas'] ?? data['service_areas'] ?? data['provider_areas'],
            );
            final selectedCityId = _cityId;
            final areasAsync = selectedCityId == null
                ? const AsyncValue<List<Map<String, dynamic>>>.data([])
                : ref.watch(providerCityAreasProvider(selectedCityId));

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'المناطق الحالية',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (currentAreas.isEmpty)
                        const Text(
                          'لا توجد مناطق خدمة مضافة بعد.',
                          style: TextStyle(color: SahelColors.muted),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final area in currentAreas)
                              InputChip(
                                label: Text(
                                  str(
                                    area['name'] ??
                                        asMap(area['area'])['name'],
                                    'منطقة',
                                  ),
                                ),
                                onDeleted: () => _deleteArea(
                                  str(area['id'] ?? asMap(area['area'])['id']),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إضافة منطقة جديدة',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      cities.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (e, _) => const Text('تعذر تحميل المدن'),
                        data: (items) => DropdownButtonFormField<String>(
                          key: ValueKey(_cityId),
                          initialValue: _cityId,
                          decoration:
                              const InputDecoration(labelText: 'المدينة'),
                          items: [
                            for (final city in items)
                              DropdownMenuItem(
                                value: str(city['id']),
                                child: Text(str(city['name'])),
                              ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _cityId = value;
                              _areaId = null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      areasAsync.when(
                        loading: () => const CircularProgressIndicator(),
                        error: (e, _) => const Text('تعذر تحميل المناطق'),
                        data: (areas) => DropdownButtonFormField<String>(
                          key: ValueKey(_areaId),
                          initialValue: _areaId,
                          decoration:
                              const InputDecoration(labelText: 'المنطقة'),
                          items: [
                            for (final area in areas)
                              DropdownMenuItem(
                                value: str(area['id']),
                                child: Text(str(area['name'])),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _areaId = value),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _saving ? null : _addArea,
                        icon: const Icon(Icons.add_location_alt_outlined),
                        label: _saving
                            ? const Text('جارٍ الحفظ...')
                            : const Text('إضافة المنطقة'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _addArea() async {
    final areaId = _areaId;
    if (areaId == null || areaId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختَر المنطقة أولاً')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(providerRepositoryProvider).storeArea({'area_id': areaId});
      ref.invalidate(providerAvailabilityProvider);
      if (!mounted) return;
      setState(() => _areaId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة منطقة الخدمة')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر إضافة المنطقة')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteArea(String id) async {
    if (id.isEmpty) return;
    try {
      await ref.read(providerRepositoryProvider).destroyArea(id);
      ref.invalidate(providerAvailabilityProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المنطقة')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حذف المنطقة')),
      );
    }
  }
}

class ProviderPortfolioScreen extends ConsumerStatefulWidget {
  const ProviderPortfolioScreen({super.key});

  @override
  ConsumerState<ProviderPortfolioScreen> createState() =>
      _ProviderPortfolioScreenState();
}

class _ProviderPortfolioScreenState
    extends ConsumerState<ProviderPortfolioScreen> {
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    final portfolio = ref.watch(providerPortfolioProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('صور الأعمال')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploading ? null : _pickAndUpload,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: Text(_uploading ? 'جارٍ الرفع...' : 'إضافة صورة'),
      ),
      body: SafeArea(
        child: portfolio.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: TextButton.icon(
              onPressed: () => ref.invalidate(providerPortfolioProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد صور أعمال حتى الآن',
                  style: TextStyle(
                    color: SahelColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final item = items[index];
                final title = str(item['title'] ?? item['name'], 'صورة عمل');
                final description = str(item['description']);
                final imageUrl = str(
                  item['image_url'] ?? item['image'] ?? item['url'],
                );

                return _SectionCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl.isEmpty
                            ? Container(
                                width: 88,
                                height: 88,
                                color: SahelColors.slate100,
                                child: const Icon(Icons.image_outlined),
                              )
                            : Image.network(
                                imageUrl,
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 88,
                                  height: 88,
                                  color: SahelColors.slate100,
                                  child: const Icon(Icons.broken_image_outlined),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                description,
                                style: const TextStyle(
                                  color: SahelColors.muted,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => _deletePortfolio(
                                str(item['id']),
                              ),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: SahelColors.red600,
                              ),
                              label: const Text(
                                'حذف',
                                style: TextStyle(color: SahelColors.red600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null || !mounted) return;

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('بيانات صورة العمل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'العنوان'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'وصف مختصر'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('رفع'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;

    final title = titleController.text.trim().isEmpty
        ? 'صورة عمل'
        : titleController.text.trim();

    setState(() => _uploading = true);
    try {
      await ref.read(providerRepositoryProvider).storePortfolio(
            title: title,
            description: descriptionController.text.trim(),
            imagePath: image.path,
          );
      ref.invalidate(providerPortfolioProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفع صورة العمل')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر رفع الصورة الآن')),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _deletePortfolio(String id) async {
    if (id.isEmpty) return;
    try {
      await ref.read(providerRepositoryProvider).destroyPortfolio(id);
      ref.invalidate(providerPortfolioProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الصورة')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حذف الصورة')),
      );
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SahelColors.slate200),
      ),
      child: child,
    );
  }
}
