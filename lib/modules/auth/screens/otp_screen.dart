import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:saber_flutter/providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController _pinController = TextEditingController();
  int _countdown = 60;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
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
    if (_pinController.text.length != 6) return;
    setState(() => _isLoading = true);
    final ok =
        await ref.read(authNotifierProvider.notifier).verifyOtp(_pinController.text);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(authNotifierProvider).errorMessage ?? 'رمز غير صحيح',
          ),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
    // On success the router redirect moves the user to their home.
  }

  @override
  Widget build(BuildContext context) {
    final defaultTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F766E),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(10.5),
        border: Border.all(color: const Color(0xFFCCFBF1)),
      ),
    );

    final focusedTheme = defaultTheme.copyWith(
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(10.5),
        border: Border.all(color: const Color(0xFF0D9488), width: 2),
      ),
    );

    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'رمز التحقق',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'أرسلنا رمزاً مكوناً من 6 أرقام إلى بريدك الإلكتروني',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Pinput(
                  controller: _pinController,
                  length: 6,
                  defaultPinTheme: defaultTheme,
                  focusedPinTheme: focusedTheme,
                  submittedPinTheme: focusedTheme,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  onCompleted: (_) => _verify(),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _countdown > 0 ? 'إعادة الإرسال بعد $_countdown ثانية ' : 'لم تستلم الرمز؟ ',
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                  TextButton(
                    onPressed: _countdown > 0 ? null : _resend,
                    child: const Text(
                      'إعادة الإرسال',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
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
                  onPressed: (_pinController.text.length == 6 && !_isLoading) ? _verify : null,
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
                          'تأكيد الرمز',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
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
}

