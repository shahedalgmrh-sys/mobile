import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/core/i18n/sahel_i18n.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/providers/settings_provider.dart';
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
    final lang = ref.read(appSettingsProvider).language;
    final auth = ref.read(authNotifierProvider);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'فشل تسجيل الدخول'.t(lang)),
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
    final lang = ref.watch(appSettingsProvider).language;

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
                    Text(
                      'مرحباً بعودتك 👋'.t(lang),
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        color: SahelColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'سجّل الدخول بحسابك للمتابعة إلى ساحل'.t(lang),
                      style: SahelTextStyles.caption,
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _loginController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني أو رقم الهاتف'.t(lang),
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
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
                        labelText: 'كلمة المرور'.t(lang),
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? 'إظهار'.t(lang) : 'إخفاء'.t(lang),
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
                        child: Text(
                          'نسيت كلمة المرور؟'.t(lang),
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SahelButton.gradient(
                      label: 'تسجيل الدخول'.t(lang),
                      loading: isLoading,
                      height: 52,
                      onPressed: _isValid && !isLoading ? _login : null,
                    ),
                    const SizedBox(height: 24),
                    const _OrDivider(),
                    const SizedBox(height: 20),
                    SahelButton.outline(
                      label: 'إنشاء حساب جديد'.t(lang),
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
    final lang = Localizations.localeOf(context).languageCode;
    return Row(
      children: [
        Expanded(child: Divider(color: SahelColors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('أو'.t(lang), style: SahelTextStyles.caption),
        ),
        Expanded(child: Divider(color: SahelColors.border)),
      ],
    );
  }
}
