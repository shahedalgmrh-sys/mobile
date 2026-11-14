import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/providers/auth_provider.dart';
import 'package:saber_flutter/shared/widgets/sahel_auth_header.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const int _length = 6;

  final TextEditingController _pinController = TextEditingController();
  int _countdown = 60;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        }
      });
      return _countdown > 0;
    });
  }

  Future<void> _resend() async {
    await ref.read(authNotifierProvider.notifier).resendOtp();
    if (!mounted) return;
    setState(() {
      _countdown = 60;
      _pinController.clear();
    });
    _startCountdown();
  }

  Future<void> _verify() async {
    if (_pinController.text.length != _length) return;
    setState(() => _isLoading = true);
    final ok = await ref
        .read(authNotifierProvider.notifier)
        .verifyOtp(_pinController.text);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(authNotifierProvider).errorMessage ?? 'رمز غير صحيح',
          ),
          backgroundColor: SahelColors.danger,
        ),
      );
    }
    // On success the router redirect moves the user to their home.
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = PinTheme(
      width: 48,
      height: 58,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: SahelColors.primary700,
      ),
      decoration: BoxDecoration(
        color: SahelColors.surface,
        borderRadius: SahelRadii.smRadius,
        border: Border.all(color: SahelColors.border),
        boxShadow: SahelElevations.xs,
      ),
    );

    final activeTheme = baseTheme.copyWith(
      decoration: BoxDecoration(
        color: SahelColors.primarySurface,
        borderRadius: SahelRadii.smRadius,
        border: Border.all(color: SahelColors.primary, width: 1.6),
      ),
    );

    final complete = _pinController.text.length == _length;

    return Scaffold(
      backgroundColor: SahelColors.bg,
      body: Stack(
        children: [
          // Subtle ambient glow behind the header (Stitch auth shell).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    SahelColors.primary.withValues(alpha: 0.10),
                    SahelColors.primary.withValues(alpha: 0.03),
                    SahelColors.bg.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SahelAuthHeader(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: _SecurityBadge(),
                        ),
                        const SizedBox(height: 24),
                        const _OtpGlyph(),
                        const SizedBox(height: 18),
                        const Text(
                          'رمز التحقق',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            height: 1.3,
                            fontWeight: FontWeight.w800,
                            color: SahelColors.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'أرسلنا رمزاً مكوّناً من 6 أرقام إلى بريدك الإلكتروني المسجّل',
                          textAlign: TextAlign.center,
                          style: SahelTextStyles.caption,
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Pinput(
                              controller: _pinController,
                              length: _length,
                              defaultPinTheme: baseTheme,
                              focusedPinTheme: activeTheme,
                              submittedPinTheme: activeTheme,
                              errorPinTheme: baseTheme.copyWith(
                                decoration: BoxDecoration(
                                  color: SahelColors.errorContainer,
                                  borderRadius: SahelRadii.smRadius,
                                  border: Border.all(
                                    color: SahelColors.danger,
                                  ),
                                ),
                              ),
                              cursor: Container(
                                width: 2,
                                height: 24,
                                color: SahelColors.primary,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              onCompleted: (_) => _verify(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              complete
                                  ? Icons.verified_outlined
                                  : Icons.info_outline,
                              size: 16,
                              color: complete
                                  ? SahelColors.success
                                  : SahelColors.textSoft,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              complete
                                  ? 'اكتمل الرمز — جاهز للتأكيد'
                                  : 'أدخل الرمز المكوّن من 6 أرقام للمتابعة',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: complete
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: complete
                                    ? SahelColors.success
                                    : SahelColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        _ResendRow(
                          countdown: _countdown,
                          onResend: _resend,
                        ),
                        const SizedBox(height: 22),
                        SahelButton.gradient(
                          label: 'تأكيد الرمز',
                          loading: _isLoading,
                          height: 52,
                          onPressed:
                              complete && !_isLoading ? _verify : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  const _SecurityBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        color: SahelColors.primarySurface,
        borderRadius: SahelRadii.pillRadius,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user, size: 16, color: SahelColors.primary),
          SizedBox(width: 6),
          Text(
            'بوابة أمان سابر',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: SahelColors.primary700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpGlyph extends StatelessWidget {
  const _OtpGlyph();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 84,
        height: 84,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: SahelColors.primarySurface,
                boxShadow: SahelElevations.xs,
              ),
            ),
            const Icon(Icons.sms_outlined,
                size: 34, color: SahelColors.primary),
            Positioned(
              bottom: 2,
              left: 6,
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: SahelColors.primary,
                ),
                child: const Icon(Icons.lock_outline,
                    size: 14, color: SahelColors.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({required this.countdown, required this.onResend});

  final int countdown;
  final Future<void> Function() onResend;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.timer_outlined,
            size: 18, color: SahelColors.textSoft),
        const SizedBox(width: 8),
        Text(
          countdown > 0
              ? 'إعادة الإرسال خلال $countdown ثانية'
              : 'لم تستلم الرمز؟',
          style: SahelTextStyles.caption,
        ),
        if (countdown == 0)
          TextButton(
            onPressed: onResend,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              foregroundColor: SahelColors.primary700,
            ),
            child: const Text(
              'إعادة الإرسال',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}
