import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';

/// Create/edit form for a provider service, mirroring the server contract
/// (`ProviderApiController@storeService/updateService`):
/// category_id (active), title ≤255, description, price ≥0,
/// duration_minutes ≥1, is_available/is_featured, images[] (create only).
class ProviderServiceFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existing;
  const ProviderServiceFormScreen({super.key, this.existing});

  bool get isEdit => existing != null;

  @override
  ConsumerState<ProviderServiceFormScreen> createState() =>
      _ProviderServiceFormScreenState();
}

class _ProviderServiceFormScreenState
    extends ConsumerState<ProviderServiceFormScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _duration = TextEditingController();
  String? _categoryId;
  bool _isAvailable = true;
  bool _isFeatured = false;
  bool _initialized = false;
  bool _saving = false;
  List<XFile> _newImages = const [];

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _price.dispose();
    _duration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    if (!_initialized) {
      _initialized = true;
      final e = widget.existing;
      if (e != null) {
        _title.text = str(e['name'] ?? e['title']);
        _description.text = str(e['description'] ?? e['short_description']);
        _price.text = toDouble(e['price']).toStringAsFixed(
          toDouble(e['price']) == toDouble(e['price']).roundToDouble() ? 0 : 2,
        );
        _duration.text = toInt(e['duration_minutes']).toString();
        _categoryId = strOrNull(
          e['category_id'] ??
              (e['category'] is Map ? e['category']['id'] : null),
        );
        _isAvailable = toBool(e['is_available'], true);
        _isFeatured = toBool(e['is_featured'], false);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'تعديل الخدمة' : 'إضافة خدمة جديدة'),
      ),
      floatingActionButton: widget.isEdit
          ? null
          : FloatingActionButton.extended(
              backgroundColor: SahelColors.primary600,
              foregroundColor: SahelColors.onPrimary,
              icon: const Icon(Icons.image_outlined),
              label: Text('صور (${_newImages.length})'),
              onPressed: _pickImages,
            ),
      body: SafeArea(
        child: categories.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: TextButton.icon(
              onPressed: () => ref.invalidate(categoriesProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('تعذر تحميل التصنيفات — إعادة المحاولة'),
            ),
          ),
          data: (cats) {
            final validCategory =
                _categoryId != null && cats.any((c) => c.id == _categoryId);
            if (!validCategory && cats.isNotEmpty && _categoryId != null) {
              _categoryId = null;
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(labelText: 'التصنيف *'),
                  items: [
                    for (final c in cats)
                      DropdownMenuItem(value: c.id, child: Text(c.name)),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _title,
                  maxLength: 255,
                  decoration: const InputDecoration(
                    labelText: 'اسم الخدمة *',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _description,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'الوصف *',
                    hintText: 'اشرح ما تشمله الخدمة وما تقدّمه للعميل',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _price,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'السعر *',
                          suffixText: '﷼',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 130,
                      child: TextField(
                        controller: _duration,
                        keyboardType: const TextInputType.numberWithOptions(),
                        decoration: const InputDecoration(
                          labelText: 'المدة (دقيقة)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _isAvailable,
                  onChanged: (v) => setState(() => _isAvailable = v),
                  title: const Text(
                    'متاحة للـحجز',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                SwitchListTile(
                  value: _isFeatured,
                  onChanged: (v) => setState(() => _isFeatured = v),
                  title: const Text(
                    'مميّزة (تبدأ في قوائم العرض)',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                if (widget.isEdit)
                  const Padding(
                    padding: EdgeInsets.all(4),
                    child: Text(
                      'ملاحظة: تعديل الخدمة لا يرفع صوراً جديدة — واجهة الـ API الحالية لا تدعم تحديث صور الخدمة.',
                      style: TextStyle(
                        fontSize: 12,
                        color: SahelColors.textMuted,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : () => _save(context),
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: SahelColors.onPrimary,
                            ),
                          )
                        : Icon(widget.isEdit ? Icons.save_outlined : Icons.add),
                    label: Text(
                      widget.isEdit ? 'حفظ التعديلات' : 'إنشاء الخدمة',
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 86);
    if (picked.isEmpty) return;
    setState(() => _newImages = [..._newImages, ...picked]);
  }

  String? _validate() {
    if (_categoryId == null) return 'اختر التصنيف أولاً';
    if (_title.text.trim().isEmpty) return 'أدخل اسم الخدمة';
    if (_title.text.trim().length > 255) return 'اسم الخدمة طويل جداً';
    if (_description.text.trim().isEmpty) return 'أدخل وصف الخدمة';
    final price = double.tryParse(_price.text.trim());
    if (price == null || price < 0) return 'أدخل سعراً صحيحاً (0 أو أكثر)';
    final duration = int.tryParse(_duration.text.trim());
    if (_duration.text.trim().isNotEmpty &&
        (duration == null || duration < 1)) {
      return 'المدة يجب أن تكون دقيقة أو أكثر';
    }
    return null;
  }

  Future<void> _save(BuildContext context) async {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(providerRepositoryProvider);
    final payload = <String, dynamic>{
      'category_id': _categoryId,
      'name': _title.text.trim(),
      'description': _description.text.trim(),
      'price': double.tryParse(_price.text.trim()) ?? 0,
      'is_available': _isAvailable,
      'is_featured': _isFeatured,
      if (_duration.text.trim().isNotEmpty)
        'duration_minutes': int.tryParse(_duration.text.trim()),
    };
    try {
      if (widget.isEdit) {
        await repo.updateService(str(widget.existing!['id']), payload);
      } else {
        final images = <MultipartFile>[
          for (final f in _newImages)
            await MultipartFile.fromFile(f.path, filename: f.name),
        ];
        await repo.storeService(payload, images: images);
      }
      ref.invalidate(providerServicesProvider);
      ref.invalidate(homeFeedProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEdit ? 'تم حفظ التعديلات ✓' : 'تم إنشاء الخدمة ✓',
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر حفظ الخدمة — حاول مجدداً')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
