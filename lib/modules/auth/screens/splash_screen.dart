import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
              Color(0xFF0F172A),
              Color(0xFF115E59),
              Color(0xFF0F766E),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            const Icon(
              Icons.water_drop,
              size: 100,
              color: Color(0xFF14B8A6),
            ),
            const SizedBox(height: 24),
            const Text(
              'SAHEL',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            const Text(
              'ساحل',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF5EEAD4),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'خدمات منزلية موثوقة على الطلب',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xDEFFFFFF),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Trusted home services delivered to your door',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xB3FFFFFF),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(flex: 3),
            const Text(
              'Version 1.0.0 (build 421)',
              style: TextStyle(
                fontSize: 11,
                color: Color(0x99FFFFFF),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: const LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2DD4BF)),
                  backgroundColor: Color(0x33FFFFFF),
                  minHeight: 2,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
