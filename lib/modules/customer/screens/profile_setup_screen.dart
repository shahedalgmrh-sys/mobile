import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/core/providers.dart';
import 'package:saber_flutter/data/repositories/parsers.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/data_providers.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  String? _cityId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    if (user != null) {
      _nameController.text = str(user['name']);
      _phoneController.text = str(user['phone']);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final name = _nameController.text.trim();
      final parts = name.split(RegExp(r'\s+'));
      await ref.read(customerRepositoryProvider).updateMe({
        'first_name': parts.first,
        if (parts.length > 1) 'last_name': parts.sublist(1).join(' '),
        if (_phoneController.text.trim().isNotEmpty)
          'phone': _phoneController.text.trim(),
        if (_bioController.text.trim().isNotEmpty)
          'bio': _bioController.text.trim(),
      });
      await ref.read(authNotifierProvider.notifier).refreshUser();
      if (mounted) context.go('/home');
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر حفظ الملف — حاول لاحقاً')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cities = ref.watch(citiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إكمال الملف الشخصي')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('أكمل بياناتك لنخصص تجربتك',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 20),
                _field(
                  label: 'الاسم الكامل',
                  hint: 'مثال: آمال أحمد',
                  controller: _nameController,
                  icon: Icons.person_outline,
                  validator: (v) => (v == null || v.trim().length < 3)
                      ? 'يرجى إدخال الاسم'
                      : null,
                ),
                const SizedBox(height: 14),
                _field(
                  label: 'رقم الهاتف',
                  hint: '+967 777 000 000',
                  controller: _phoneController,
                  icon: Icons.phone_iphone,
                  type: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                const Text('المدينة',
                    style: TextStyle(
                        fontSize: 12,
                        color: SahelColors.muted,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_city,
                        color: SahelColors.primary600),
                    border:
                        OutlineInputBorder(borderRadius: SahelRadii.mdRadius),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 2),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _cityId,
                      hint: const Text('اختر مدينتك',
                          style: TextStyle(color: SahelColors.muted)),
                      items: [
                        for (final c in cities.valueOrNull ?? const [])
                          DropdownMenuItem<String>(
                            value: str(c['id']),
                            child: Text(
                                str(c['name'] ?? c['name_ar'] ?? c['title']),
                                style: const TextStyle(fontSize: 14)),
                          ),
                      ],
                      onChanged: (v) => setState(() => _cityId = v),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _field(
                  label: 'نبذة قصيرة (اختياري)',
                  hint: 'مثال: أبحث عن خدمات تنظيف دورية',
                  controller: _bioController,
                  icon: Icons.notes,
                  maxLines: 3,
                ),
                const SizedBox(height: 28),
                _saving
                    ? const Center(child: CircularProgressIndicator())
                    : SahelButton.gradient(
                        label: 'حفظ والانتقال إلى الرئيسية',
                        onPressed: _save,
                      ),
                const SizedBox(height: 14),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('تخطي الآن',
                        style: TextStyle(
                            color: SahelColors.muted,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? type,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: SahelColors.muted,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: type,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: SahelColors.muted, fontSize: 13),
            prefixIcon: Icon(icon, color: SahelColors.primary600),
            border:
                const OutlineInputBorder(borderRadius: SahelRadii.mdRadius),
            enabledBorder: const OutlineInputBorder(
                borderRadius: SahelRadii.mdRadius,
                borderSide:
                    BorderSide(color: SahelColors.slate200)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }
}
