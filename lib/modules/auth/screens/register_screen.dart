import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/core/constants/enums.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/shared/widgets/sahel_auth_header.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.initialRole});

  final UserRole? initialRole;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  late UserRole _selectedRole = widget.initialRole ?? UserRole.customer;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // Provider accreditation documents. The API accepts `documents[]` as
  // multipart files (pdf/jpeg/png, max 10MB each).
  static const int _maxDocumentBytes = 10 * 1024 * 1024;
  static const List<String> _allowedDocumentExtensions = [
    'pdf',
    'jpg',
    'jpeg',
    'png',
  ];
  final List<PlatformFile> _documents = [];
  bool _isPickingDocuments = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _isEmail(String v) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());

  Future<void> _pickDocuments() async {
    setState(() => _isPickingDocuments = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: _allowedDocumentExtensions,
      );
      if (result == null) return;
      final rejected = <String>[];
      final accepted = <PlatformFile>[];
      for (final file in result.files) {
        final path = file.path;
        final extension = (file.extension ?? '').toLowerCase();
        if (path == null || path.isEmpty) continue;
        if (!_allowedDocumentExtensions.contains(extension)) {
          rejected.add('${file.name}: صيغة غير مدعومة');
          continue;
        }
        if (file.size > _maxDocumentBytes) {
          rejected.add('${file.name}: يتجاوز 10 ميجابايت');
          continue;
        }
        if (_documents.any((d) => d.path == path)) continue;
        accepted.add(file);
      }
      if (!mounted) return;
      setState(() => _documents.addAll(accepted));
      if (rejected.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(rejected.join('\n'))),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح منتقي الملفات. حاول مرة أخرى.')),
      );
    } finally {
      if (mounted) setState(() => _isPickingDocuments = false);
    }
  }

  String _documentSize(int bytes) {
    final mb = bytes / (1024 * 1024);
    if (mb >= 1) return '${mb.toStringAsFixed(1)} ميجابايت';
    return '${(bytes / 1024).ceil()} كيلوبايت';
  }

  Future<void> _register() async {
    setState(() => _isLoading = true);
    final ok = await ref.read(authNotifierProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
          documentPaths: _selectedRole == UserRole.provider
              ? [
                  for (final document in _documents)
                    if (document.path != null) document.path!,
                ]
              : null,
        );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) {
      // Keep the OTP step for providers; the router then lands them on
      // /p/kyc or /p/dashboard from the API accreditation status.
      context.go('/otp');
    } else {
      final msg = ref.read(authNotifierProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg ?? 'فشل إنشاء الحساب'),
          backgroundColor: SahelColors.danger,
        ),
      );
    }
  }

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _isEmail(_emailController.text) &&
      _passwordController.text.length >= 8 &&
      _passwordController.text == _confirmController.text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SahelColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SahelAuthHeader(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'إنشاء حساب جديد',
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        color: SahelColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'انضم إلى سابر واحصل على أفضل الخدمات المنزلية',
                      style: SahelTextStyles.caption,
                    ),
                    const SizedBox(height: 24),
                    _RoleOption(
                      icon: Icons.person_outline,
                      title: 'أنا عميل',
                      subtitle: 'أبحث عن خدمات منزلية',
                      selected: _selectedRole == UserRole.customer,
                      onTap: () =>
                          setState(() => _selectedRole = UserRole.customer),
                    ),
                    const SizedBox(height: 12),
                    _RoleOption(
                      icon: Icons.build_outlined,
                      title: 'مزود خدمة',
                      subtitle: 'أقدّم خدماتي للعملاء',
                      selected: _selectedRole == UserRole.provider,
                      onTap: () =>
                          setState(() => _selectedRole = UserRole.provider),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'الاسم الكامل',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف (اختياري)',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: Icon(Icons.email_outlined, size: 20),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePass,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        helperText: '8 أحرف على الأقل',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          tooltip: _obscurePass ? 'إظهار' : 'إخفاء',
                          icon: Icon(
                            _obscurePass
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'تأكيد كلمة المرور',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          tooltip: _obscureConfirm ? 'إظهار' : 'إخفاء',
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    if (_selectedRole == UserRole.provider) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: SahelColors.primarySurface,
                          borderRadius: SahelRadii.mdRadius,
                          border: Border.all(color: SahelColors.primary100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.verified_user_outlined,
                                  size: 20,
                                  color: SahelColors.primary700,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'ملف مزود الخدمة',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: SahelColors.text,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'سيُستخدم اسمك الكامل اسماً تجارياً مبدئياً، ويمكنك تعديل اسم النشاط والنبذة من إعدادات الملف بعد إنشاء الحساب.',
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.6,
                                color: SahelColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'وثائق الاعتماد (اختياري)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: SahelColors.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'PDF أو JPG أو PNG — بحد أقصى 10 ميجابايت للملف.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color: SahelColors.textMuted,
                              ),
                            ),
                            if (_documents.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              for (final document in _documents)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: SahelColors.surface,
                                    borderRadius: SahelRadii.smRadius,
                                    border: Border.all(color: SahelColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        (document.extension ?? '').toLowerCase() ==
                                                'pdf'
                                            ? Icons.picture_as_pdf_outlined
                                            : Icons.image_outlined,
                                        size: 20,
                                        color: SahelColors.primary700,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              document.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700,
                                                color: SahelColors.text,
                                              ),
                                            ),
                                            Text(
                                              _documentSize(document.size),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: SahelColors.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'إزالة',
                                        visualDensity: VisualDensity.compact,
                                        onPressed: _isLoading
                                            ? null
                                            : () => setState(
                                                  () => _documents
                                                      .remove(document),
                                                ),
                                        icon: const Icon(Icons.close, size: 18),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                            const SizedBox(height: 10),
                            SahelButton.outline(
                              label: 'اختيار الوثائق',
                              icon: Icons.upload_file_outlined,
                              loading: _isPickingDocuments,
                              height: 44,
                              onPressed: _isLoading || _isPickingDocuments
                                  ? null
                                  : _pickDocuments,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    SahelButton.gradient(
                      label: 'إنشاء حساب',
                      loading: _isLoading,
                      height: 52,
                      onPressed: _isValid && !_isLoading ? _register : null,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'لديك حساب بالفعل؟',
                          style: SahelTextStyles.caption,
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            foregroundColor: SahelColors.primary700,
                          ),
                          child: const Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: SahelRadii.mdRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? SahelColors.primarySurface : SahelColors.surface,
          borderRadius: SahelRadii.mdRadius,
          border: Border.all(
            color: selected ? SahelColors.primary : SahelColors.border,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: SahelElevations.xs,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? SahelColors.primary
                    : SahelColors.primarySurface,
                borderRadius: SahelRadii.smRadius,
              ),
              child: Icon(
                icon,
                size: 22,
                color: selected ? SahelColors.onPrimary : SahelColors.primary700,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: SahelColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: SahelColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              size: 22,
              color: selected ? SahelColors.primary : SahelColors.slate300,
            ),
          ],
        ),
      ),
    );
  }
}
