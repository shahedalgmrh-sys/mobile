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

/// Two-step password recovery mirroring the API contract:
///
/// 1. `POST /auth/forgot-password` emails a reset link — the token only ever
///    exists inside the email, never in the API response.
/// 2. `POST /auth/reset-password` consumes that token together with the new
///    password.
///
/// The token field can be prefilled when the user opens the app through the
/// `https://<host>/reset-password/{token}?email=…` deep link; otherwise it is
/// pasted manually from the email, which also works before the app-link
/// domain is verified.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    this.initialEmail = '',
    this.initialToken = '',
  });

  /// Prefilled from the email deep link when available.
  final String initialEmail;
  final String initialToken;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late final TextEditingController _emailController =
      TextEditingController(text: widget.initialEmail);
  late final TextEditingController _tokenController =
      TextEditingController(text: widget.initialToken);
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscure = true;

  /// Deep-link arrivals with a token land directly on the reset step.
  bool _stepTwo = false;

  @override
  void initState() {
    super.initState();
    _stepTwo = widget.initialToken.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _emailValid => _emailController.text.trim().contains('@');

  bool get _resetValid =>
      _tokenController.text.trim().isNotEmpty &&
      _passwordController.text.length >= 8 &&
      _passwordController.text == _confirmController.text;

  Future<void> _request() async {
    final msg = await ref
        .read(authNotifierProvider.notifier)
        .forgotPassword(_emailController.text.trim());
    if (!mounted) return;
    if (msg != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: SahelColors.danger),
      );
      return;
    }
    setState(() => _stepTwo = true);
  }

  Future<void> _reset() async {
    final msg = await ref.read(authNotifierProvider.notifier).resetPassword(
          email: _emailController.text.trim(),
          token: _tokenController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    final lang = ref.read(appSettingsProvider).language;
    if (msg != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: SahelColors.danger),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تغيير كلمة المرور بنجاح. سجّل الدخول بكلمة المرور الجديدة.'.t(lang),
        ),
        backgroundColor: SahelColors.primary700,
      ),
    );
    context.go('/login');
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
              child: SahelAuthHeader(showBack: true),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                child: _stepTwo
                    ? _buildResetStep(isLoading, lang)
                    : _buildRequestStep(isLoading, lang),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------- Step 1: email

  Widget _buildRequestStep(bool isLoading, String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'استعادة كلمة المرور'.t(lang),
          style: const TextStyle(
            fontSize: 28,
            height: 1.3,
            fontWeight: FontWeight.w800,
            color: SahelColors.text,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور'.t(lang),
          style: SahelTextStyles.caption,
        ),
        const SizedBox(height: 28),
        TextField(
          key: const Key('fp_email'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (_emailValid && !isLoading) _request();
          },
          decoration: InputDecoration(
            labelText: 'البريد الإلكتروني'.t(lang),
            prefixIcon: const Icon(Icons.alternate_email, size: 20),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        SahelButton.gradient(
          label: 'إرسال رابط الاستعادة'.t(lang),
          loading: isLoading,
          height: 52,
          onPressed: _emailValid && !isLoading ? _request : null,
        ),
      ],
    );
  }

  // ------------------------------------------- Step 2: token + new password

  Widget _buildResetStep(bool isLoading, String lang) {
    final mismatch = _confirmController.text.isNotEmpty &&
        _passwordController.text != _confirmController.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'إعادة تعيين كلمة المرور'.t(lang),
          style: const TextStyle(
            fontSize: 28,
            height: 1.3,
            fontWeight: FontWeight.w800,
            color: SahelColors.text,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'أدخل الرمز المرسل إلى بريدك الإلكتروني واختر كلمة مرور جديدة'.t(lang),
          style: SahelTextStyles.caption,
        ),
        const SizedBox(height: 28),
        TextField(
          key: const Key('fp_token'),
          controller: _tokenController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'رمز التحقق من البريد'.t(lang),
            prefixIcon: const Icon(Icons.key_outlined, size: 20),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('fp_password'),
          controller: _passwordController,
          obscureText: _obscure,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'كلمة المرور الجديدة'.t(lang),
            helperText: '8 أحرف على الأقل'.t(lang),
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
        const SizedBox(height: 16),
        TextField(
          key: const Key('fp_confirm'),
          controller: _confirmController,
          obscureText: _obscure,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (_resetValid && !isLoading) _reset();
          },
          decoration: InputDecoration(
            labelText: 'تأكيد كلمة المرور الجديدة'.t(lang),
            errorText: mismatch ? 'كلمتا المرور غير متطابقتين'.t(lang) : null,
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        SahelButton.gradient(
          label: 'إعادة تعيين كلمة المرور'.t(lang),
          loading: isLoading,
          height: 52,
          onPressed: _resetValid && !isLoading ? _reset : null,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: isLoading ? null : () => setState(() => _stepTwo = false),
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            foregroundColor: SahelColors.primary700,
          ),
          child: Text(
            'طلب رابط جديد'.t(lang),
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
