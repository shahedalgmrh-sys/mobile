import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/shared/widgets/sahel_auth_header.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _loginController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty;

  Future<void> _login() async {
    final ok = await ref.read(authNotifierProvider.notifier).login(
          login: _loginController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    final auth = ref.read(authNotifierProvider);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'فشل تسجيل الدخول'),
          backgroundColor: SahelColors.danger,
        ),
      );
      return;
    }
    if (!auth.isVerified) {
      context.go('/otp');
      return;
    }
    // Router redirect handles role-based landing.
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: SahelColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SahelAuthHeader(showBack: false),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'مرحباً بعودتك 👋',
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        color: SahelColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'سجّل الدخول بحسابك للمتابعة إلى ساحل',
                      style: SahelTextStyles.caption,
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _loginController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني أو رقم الهاتف',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        if (_isValid && !isLoading) _login();
                      },
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? 'إظهار' : 'إخفاء',
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          foregroundColor: SahelColors.primary700,
                        ),
                        child: const Text(
                          'نسيت كلمة المرور؟',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SahelButton.gradient(
                      label: 'تسجيل الدخول',
                      loading: isLoading,
                      height: 52,
                      onPressed: _isValid && !isLoading ? _login : null,
                    ),
                    const SizedBox(height: 24),
                    const _OrDivider(),
                    const SizedBox(height: 20),
                    SahelButton.outline(
                      label: 'إنشاء حساب جديد',
                      height: 52,
                      prefixIcon: Icons.person_add_alt,
                      onPressed: () => context.go('/register'),
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

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: SahelColors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('أو', style: SahelTextStyles.caption),
        ),
        Expanded(child: Divider(color: SahelColors.border)),
      ],
    );
  }
}
