import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/models/booking_status.dart';
import 'package:saber_flutter/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1800), () async {
        await ref.read(authNotifierProvider.notifier).checkSession();
        if (!mounted) return;
        final state = ref.read(authNotifierProvider);
        if (!state.isAuthenticated) {
          context.go('/login');
        } else if (!state.isVerified) {
          context.go('/otp');
        } else if (state.role == UserRole.provider) {
          context.go('/p/dashboard');
        } else {
          context.go('/home');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              SahelColors.slate900,
              SahelColors.primary800,
              SahelColors.primary600,
            ],
          ),
        ),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: const Icon(
                Icons.water_drop,
                size: 48,
                color: SahelColors.primary300,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'SAHEL',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'ساحل',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: SahelColors.primary300,
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'خدمات منزلية موثوقة على الطلب',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Color(0xDEFFFFFF),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 56),
              child: ClipRRect(
                borderRadius: SahelRadii.pillRadius,
                child: const LinearProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(SahelColors.primary300),
                  backgroundColor: Color(0x33FFFFFF),
                  minHeight: 3,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 11,
                color: Color(0x99FFFFFF),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
