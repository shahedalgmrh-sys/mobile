import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  children: [
                    _buildSlide(
                      icon: Icons.home_repair_service,
                      iconColor: const Color(0xFF0D9488),
                      title: 'ابحث عن أي خدمة منزلية',
                      subtitle:
                          'من تنظيف وصيانة إلى سباكة وكهرباء — أكثر من 40 فئة مع فنيين موثقين.\n\nSearch for any home service.',
                    ),
                    _buildSlide(
                      icon: Icons.verified_user,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'مزودين موثقين بتصريح رسمي',
                      subtitle:
                          'كل مقدم خدمة يمر بمراجعة وثائق KYC ودورات تدريب قبل الانضمام.\n\nEvery provider is verified.',
                    ),
                    _buildSlide(
                      icon: Icons.track_changes,
                      iconColor: const Color(0xFF059669),
                      title: 'تتبع مباشر ودفع آمن',
                      subtitle:
                          'عرف مكان الفني دقيقة بدقيقة، وادفع بأي طريقة: بطاقة، محفظة، كاش.\n\nReal-time tracking + wallet.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == i
                          ? const Color(0xFF0F766E)
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
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
                  onPressed: () {
                    if (_currentIndex < 2) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    } else {
                      context.go('/language');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.5),
                    ),
                  ),
                  child: Text(
                    _currentIndex < 2 ? 'التالي' : 'ابدأ الآن',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
        ),
      ),
    );
  }

  Widget _buildSlide({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 120, color: iconColor),
        const SizedBox(height: 32),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF64748B),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
