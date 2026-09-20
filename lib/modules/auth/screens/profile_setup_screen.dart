import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saber_flutter/sahel_theme/sahel_colors.dart';
import 'package:saber_flutter/sahel_theme/sahel_radii.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';
import 'package:saber_flutter/modules/customer/customer_shell.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _avatarImage;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(text: '+967 777 ');
  String? _selectedCity;
  final _cities = const [
    'صنعاء',
    'عدن',
    'تعز',
    'الحديدة',
    'إب',
    'ذمار',
    'مأرب',
    'البيضاء',
    'حضرموت',
    'سقطرى',
  ];
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar(ImageSource src) async {
    final img = await _picker.pickImage(source: src, imageQuality: 85, maxWidth: 512);
    if (img != null) {
      setState(() => _avatarImage = img);
    }
  }

  void _showAvatarSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: SahelColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(width: 48, height: 5, decoration: BoxDecoration(color: SahelColors.surface3, borderRadius: BorderRadius.circular(3))),
            ),
            const SizedBox(height: 20),
            const Text('اختر صورة الملف الشخصي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: SahelColors.primary50, borderRadius: SahelRadii.smRadius), child: const Icon(Icons.photo_library, color: SahelColors.primary600)),
              title: const Text('المعرض', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('اختر من صورك المخزنة', style: TextStyle(fontSize: 12, color: SahelColors.textMuted)),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickAvatar(ImageSource.gallery);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: SahelColors.amberSoft, borderRadius: SahelRadii.smRadius), child: const Icon(Icons.camera_alt, color: SahelColors.amber)),
              title: const Text('الكاميرا', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('التقاط صورة فورية', style: TextStyle(fontSize: 12, color: SahelColors.textMuted)),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickAvatar(ImageSource.camera);
              },
            ),
            if (_avatarImage != null) ...[
              const Divider(height: 1),
              ListTile(
                leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: SahelColors.dangerSoft, borderRadius: SahelRadii.smRadius), child: const Icon(Icons.delete_outline, color: SahelColors.danger)),
                title: const Text('إزالة الصورة', style: TextStyle(fontWeight: FontWeight.w700, color: SahelColors.danger)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  setState(() => _avatarImage = null);
                },
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: SahelColors.nightGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('أكمل إنشاء حسابك', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                          SizedBox(height: 4),
                          Text('إعداد الملف الشخصي خطوة سريعة', style: TextStyle(color: SahelColors.primary200, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), shape: BoxShape.circle),
                      child: const Text('٤/٤', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: SahelColors.bg,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: InkWell(
                              onTap: _showAvatarSheet,
                              borderRadius: BorderRadius.circular(999),
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 56,
                                    backgroundColor: SahelColors.primary100,
                                    backgroundImage: null,
                                    child: _avatarImage != null
                                        ? ClipOval(
                                            child: Container(
                                              width: 112,
                                              height: 112,
                                              decoration: const BoxDecoration(color: SahelColors.surface3, shape: BoxShape.circle),
                                              child: const Icon(Icons.image, color: SahelColors.textMuted, size: 40),
                                            ),
                                          )
                                        : const Icon(Icons.person, color: SahelColors.primary700, size: 60),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        gradient: SahelColors.primaryGradient,
                                        shape: BoxShape.circle,
                                        border: const Border.fromBorderSide(BorderSide(color: Colors.white, width: 3)),
                                        boxShadow: [BoxShadow(color: SahelColors.shadowSm, blurRadius: 4, offset: Offset(0, 1))],
                                      ),
                                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton.icon(
                              onPressed: _showAvatarSheet,
                              icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                              label: const Text('رفع صورة شخصية', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildField(
                            label: 'الاسم الكامل',
                            hint: 'مثال: آمال أحمد عبدالله',
                            controller: _nameController,
                            icon: Icons.person_outline,
                            required: true,
                            validator: (v) => (v == null || v.trim().length < 4) ? 'يرجى إدخال اسم كامل صحيح' : null,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            label: 'البريد الإلكتروني (اختياري)',
                            hint: 'name@example.com',
                            controller: _emailController,
                            icon: Icons.email_outlined,
                            type: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) return null;
                              final ok = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v);
                              return ok ? null : 'صيغة البريد غير صالحة';
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            label: 'رقم الهاتف',
                            hint: '+967 777 123 456',
                            controller: _phoneController,
                            icon: Icons.phone_iphone,
                            type: TextInputType.phone,
                            required: true,
                            enabled: false,
                          ),
                          const SizedBox(height: 14),
                          const Text('المدينة', style: TextStyle(fontSize: 12, color: SahelColors.textMuted, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          InputDecorator(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.location_city, color: SahelColors.primary600),
                              border: OutlineInputBorder(borderRadius: SahelRadii.mdRadius),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              errorText: _selectedCity == null ? 'يرجى اختيار المدينة' : null,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedCity,
                                hint: const Text('اختر مدينتك', style: TextStyle(color: SahelColors.textSoft)),
                                items: _cities
                                    .map((c) => DropdownMenuItem<String>(value: c, child: Text(c, style: const TextStyle(fontSize: 14))))
                                    .toList(),
                                onChanged: (v) => setState(() => _selectedCity = v),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          SahelButton.gradient(
                            label: 'حفظ والانتقال إلى الرئيسية',
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                if (_selectedCity == null) {
                                  setState(() {});
                                  return;
                                }
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const CustomerShell()),
                                  (_) => false,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const CustomerShell()),
                                  (_) => false,
                                );
                              },
                              child: const Text(
                                'تخطي الآن (سأكمل لاحقاً)',
                                style: TextStyle(color: SahelColors.textMuted, fontWeight: FontWeight.w700, decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? type,
    String? Function(String?)? validator,
    bool required = false,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: SahelColors.textMuted, fontWeight: FontWeight.w600)),
            if (required) const Text(' *', style: TextStyle(color: SahelColors.danger, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: type,
          enabled: enabled,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: SahelColors.textSoft, fontSize: 13),
            prefixIcon: Icon(icon, color: SahelColors.primary600),
            filled: enabled ? false : true,
            fillColor: enabled ? null : SahelColors.surface2,
            border: OutlineInputBorder(borderRadius: SahelRadii.mdRadius),
            enabledBorder: OutlineInputBorder(borderRadius: SahelRadii.mdRadius, borderSide: const BorderSide(color: SahelColors.border)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }
}
