import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/models/booking_status.dart';
import 'package:saber_flutter/providers/auth_provider.dart';

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

  bool _isEmail(String v) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());

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
        );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) {
      context.go('/otp');
    } else {
      final msg = ref.read(authNotifierProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg ?? 'فشل إنشاء الحساب'),
          backgroundColor: const Color(0xFFDC2626),
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
      appBar: AppBar(elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إنشاء حساب جديد',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'أنضم إلى ساحل واحصل على أفضل الخدمات المنزلية',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline, size: 18),
                          SizedBox(width: 6),
                          Text('عميل'),
                        ],
                      ),
                      selected: _selectedRole == UserRole.customer,
                      selectedColor: const Color(0xFFCCFBF1),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _selectedRole == UserRole.customer
                            ? const Color(0xFF0F766E)
                            : const Color(0xFF64748B),
                      ),
                      backgroundColor: const Color(0xFFF1F5F9),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.5),
                        side: BorderSide(
                          color: _selectedRole == UserRole.customer
                              ? const Color(0xFF14B8A6)
                              : Colors.transparent,
                        ),
                      ),
                      onSelected: (_) => setState(() => _selectedRole = UserRole.customer),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.build_outlined, size: 18),
                          SizedBox(width: 6),
                          Text('مزود خدمة'),
                        ],
                      ),
                      selected: _selectedRole == UserRole.provider,
                      selectedColor: const Color(0xFFCCFBF1),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _selectedRole == UserRole.provider
                            ? const Color(0xFF0F766E)
                            : const Color(0xFF64748B),
                      ),
                      backgroundColor: const Color(0xFFF1F5F9),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.5),
                        side: BorderSide(
                          color: _selectedRole == UserRole.provider
                              ? const Color(0xFF14B8A6)
                              : Colors.transparent,
                        ),
                      ),
                      onSelected: (_) => setState(() => _selectedRole = UserRole.provider),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePass,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D9488), Color(0xFF14B8A6), Color(0xFF2DD4BF)],
                  ),
                  borderRadius: BorderRadius.circular(10.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x4014B8A6),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isValid && !_isLoading ? _register : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.5),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'إنشاء حساب',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'لديك حساب بالفعل؟ ',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

