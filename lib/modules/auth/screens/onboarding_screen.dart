import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';

/// Stitch "رحلة التهيئة واختيار الدور" — 5-step onboarding journey:
/// welcome → smart discovery → direct chat → live tracking → role selection.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _steps = 5;

  final PageController _pageController = PageController();
  int _step = 0;
  String? _role; // 'customer' | 'provider'

  bool get _isLast => _step == _steps - 1;
  bool get _canProceed => !_isLast || _role != null;

  void _next() {
    if (_isLast) {
      if (_role != null) context.go('/register?role=$_role');
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SahelColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            const SizedBox(height: 4),
            _progress(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _step = i),
                children: [
                  const _WelcomeStep(),
                  const _DiscoverStep(),
                  const _ChatStep(),
                  const _TrackStep(),
                  _RoleStep(
                    selected: _role,
                    onSelect: (r) => setState(() => _role = r),
                  ),
                ],
              ),
            ),
            _cta(),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: _step > 0
                ? () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic)
                : null,
            icon: const Icon(Icons.arrow_back),
            color: _step > 0 ? SahelColors.text : SahelColors.slate300,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
              color: SahelColors.primary100,
              borderRadius: SahelRadii.pillRadius,
            ),
            child: Text(
              'الخطوة ${_step + 1} من $_steps',
              style: const TextStyle(
                color: SahelColors.primary700,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text(
              'تخطي',
              style: TextStyle(
                color: SahelColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progress() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_steps, (i) {
        final active = i == _step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 26 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? SahelColors.primary600 : SahelColors.slate200,
            borderRadius: SahelRadii.pillRadius,
          ),
        );
      }),
    );
  }

  Widget _cta() {
    final label = _isLast
        ? 'الانتقال لإنشاء الحساب'
        : (_step == 0 ? 'ابدأ الآن' : 'التالي');
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SahelButton.gradient(
        label: label,
        height: 56,
        prefixIcon: Icons.arrow_forward,
        onPressed: _canProceed ? _next : null,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1 — Welcome
// ---------------------------------------------------------------------------
class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 28),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: SahelColors.onPrimary,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: SahelElevations.glow,
                ),
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: SahelColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.home_outlined,
                        color: SahelColors.onPrimary, size: 40),
                  ),
                ),
              ),
              Positioned(
                bottom: -10,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: SahelColors.onPrimary,
                      borderRadius: SahelRadii.pillRadius,
                      border: Border.all(color: SahelColors.slate200),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle,
                            size: 8, color: SahelColors.success),
                        SizedBox(width: 4),
                        Text('موثوق ١٠٠٪',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: SahelColors.text)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const _Pill(label: 'أهلاً بك في ساحل', icon: Icons.auto_awesome),
          const SizedBox(height: 18),
          const Text(
            'خدمات منزلك المثالية…',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: SahelColors.text,
              height: 1.3,
            ),
          ),
          const Text(
            'بضغطة زر واحدة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: SahelColors.primary600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'المنصة السعودية الرائدة التي تجمعك بنخبة مزودي الخدمات المنزلية المعتمدين والموثقين بأعلى معايير الجودة والأمان.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: SahelColors.textMuted,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 24),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _TrustChip(icon: Icons.verified_user, label: 'فنيون معتمدون'),
              _TrustChip(
                  icon: Icons.workspace_premium,
                  label: 'ضمان الجودة والأسعار'),
              _TrustChip(
                  icon: Icons.account_balance_wallet,
                  label: 'دفع إلكتروني آمن'),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2 — Smart discovery
// ---------------------------------------------------------------------------
class _DiscoverStep extends StatelessWidget {
  const _DiscoverStep();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(height: 24),
          _StepIcon(icon: Icons.explore, color: SahelColors.primary),
          SizedBox(height: 18),
          _StepTitle('اكتشف بكل راحة'),
          SizedBox(height: 20),
          _MockCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.search, color: SahelColors.textMuted),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('ابحث عن صيانة تكييف، سباكة…',
                          style: TextStyle(
                              color: SahelColors.textSoft, fontSize: 13)),
                    ),
                    Icon(Icons.location_on,
                        size: 16, color: SahelColors.primary),
                    Text('الرياض',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: SahelColors.primary700)),
                  ],
                ),
                Divider(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ServiceChip('تنظيف منازل', 'يبدأ من ٩٩ ر.س'),
                    _ServiceChip('سباكة وكهرباء', 'طوارئ ٢٤/٧'),
                    _ServiceChip('تكييف وتبريد', 'فحص وضمان'),
                    _ServiceChip('دهانات وديكور', 'تشطيب فاخر'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          _FeatureLine(
            icon: Icons.location_on,
            text: 'تصفح ذكي وبحث فوري في الرياض وجميع مدن المملكة.',
          ),
          _FeatureLine(
            icon: Icons.loyalty,
            text: 'عروض وباقات حصرية بأسعار تنافسية ومحددة مسبقاً.',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3 — Direct chat
// ---------------------------------------------------------------------------
class _ChatStep extends StatelessWidget {
  const _ChatStep();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const _StepIcon(icon: Icons.forum, color: SahelColors.primary),
          const SizedBox(height: 18),
          const _StepTitle('تواصل سريع ومباشر'),
          const SizedBox(height: 20),
          _MockCard(
            child: Column(
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: SahelColors.primary100,
                      child: Icon(Icons.engineering,
                          color: SahelColors.primary700),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('م. أحمد الزهراني',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14)),
                            SizedBox(width: 4),
                            Icon(Icons.check_circle,
                                size: 15, color: SahelColors.primary),
                          ],
                        ),
                        Text('فني تكييف معتمد • ٤.٩ ★',
                            style: TextStyle(
                                fontSize: 12,
                                color: SahelColors.textMuted)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SahelColors.surface2,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'أهلاً! هل يمكنك وصف المشكلة أو إرسال صورة للتكييف؟',
                    style: TextStyle(fontSize: 13, height: 1.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _FeatureLine(
            icon: Icons.lock,
            text: 'محادثة مباشرة ومشفرة بدون وسيط وبأمان تام.',
          ),
          const _FeatureLine(
            icon: Icons.add_a_photo,
            text: 'إمكانية مشاركة موقع المنزل وصور المشكلة بضغطة زر.',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 4 — Live tracking
// ---------------------------------------------------------------------------
class _TrackStep extends StatelessWidget {
  const _TrackStep();

  @override
  Widget build(BuildContext context) {
    const stages = ['الانتظار', 'القبول', 'قيد التنفيذ', 'مكتمل'];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const _StepIcon(
              icon: Icons.track_changes, color: SahelColors.primary),
          const SizedBox(height: 18),
          const _StepTitle('متابعة لحظية وموثقة'),
          const SizedBox(height: 20),
          _MockCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.receipt_long,
                        size: 16, color: SahelColors.textMuted),
                    SizedBox(width: 6),
                    Text('رقم الطلب #SH-8841',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: SahelColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('صيانة شاملة ونظافة فلاتر',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    for (var i = 0; i < stages.length; i++) ...[
                      _TrackDot(
                        label: stages[i],
                        done: i <= 2,
                        active: i == 2,
                      ),
                      if (i < stages.length - 1)
                        const Expanded(
                          child: Divider(
                              color: SahelColors.primary300, thickness: 2),
                        ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _FeatureLine(
            icon: Icons.notifications_active,
            text: 'إشعارات فورية عند كل تحديث في حالة الطلب.',
          ),
          const _FeatureLine(
            icon: Icons.published_with_changes,
            text: 'سجل موثق لكل مرحلة من لحظة القبول حتى الإنجاز.',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 5 — Role selection
// ---------------------------------------------------------------------------
class _RoleStep extends StatelessWidget {
  const _RoleStep({required this.selected, required this.onSelect});

  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const _StepIcon(
              icon: Icons.task_alt, color: SahelColors.primary),
          const SizedBox(height: 18),
          const _Pill(label: 'الخطوة النهائية', icon: Icons.flag),
          const SizedBox(height: 12),
          const _StepTitle('يرجى اختيار نوع الحساب للمتابعة'),
          const SizedBox(height: 24),
          _RoleCard(
            icon: Icons.person,
            title: 'أنا عميل (أبحث عن خدمات)',
            perks: const ['حجز فوري', 'ضمان ساحل'],
            selected: selected == 'customer',
            onTap: () => onSelect('customer'),
          ),
          const SizedBox(height: 14),
          _RoleCard(
            icon: Icons.storefront,
            title: 'أنا مزود خدمة (أقدم خدماتي)',
            perks: const ['عملاء مستمرون', 'تسوية أسبوعية'],
            selected: selected == 'provider',
            onTap: () => onSelect('provider'),
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.login, size: 18),
            label: const Text('لدي حساب بالفعل — تسجيل الدخول'),
            style: TextButton.styleFrom(
                foregroundColor: SahelColors.primary700),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared pieces
// ---------------------------------------------------------------------------
class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: SahelColors.primary50,
        borderRadius: SahelRadii.pillRadius,
        border: Border.all(color: SahelColors.primary100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: SahelColors.primary700),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: SahelColors.primary700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: SahelColors.onPrimary,
        borderRadius: SahelRadii.pillRadius,
        border: Border.all(color: SahelColors.border),
        boxShadow: SahelElevations.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: SahelColors.primary),
          const SizedBox(width: 6),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: SahelColors.onPrimary,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SahelColors.border),
        boxShadow: SahelElevations.md,
      ),
      child: Icon(icon, size: 36, color: color),
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: SahelColors.text,
        height: 1.35,
      ),
    );
  }
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: SahelColors.primary600),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                color: SahelColors.textMuted,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockCard extends StatelessWidget {
  const _MockCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SahelColors.onPrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SahelColors.border),
        boxShadow: SahelElevations.sm,
      ),
      child: child,
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip(this.name, this.hint);

  final String name;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: SahelColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SahelColors.slate200),
      ),
      child: Column(
        children: [
          Text(name,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(hint,
              style:
                  const TextStyle(fontSize: 10, color: SahelColors.textMuted)),
        ],
      ),
    );
  }
}

class _TrackDot extends StatelessWidget {
  const _TrackDot(
      {required this.label, required this.done, required this.active});

  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: done ? SahelColors.primary600 : SahelColors.slate200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            done ? Icons.check : Icons.circle,
            size: 13,
            color: SahelColors.onPrimary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            color: active ? SahelColors.primary700 : SahelColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.perks,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final List<String> perks;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: SahelColors.onPrimary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? SahelColors.primary600 : SahelColors.slate200,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? SahelColors.primary.withValues(alpha: 0.15)
                  : SahelColors.shadowSm,
              blurRadius: selected ? 20 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: selected
                    ? SahelColors.primary600
                    : SahelColors.primary50,
                borderRadius: SahelRadii.mdRadius,
              ),
              child: Icon(
                icon,
                color: selected ? SahelColors.onPrimary : SahelColors.primary700,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
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
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final p in perks)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: const BoxDecoration(
                            color: SahelColors.primary50,
                            borderRadius: SahelRadii.pillRadius,
                          ),
                          child: Text(
                            p,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: SahelColors.primary700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? SahelColors.primary600 : SahelColors.slate300,
            ),
          ],
        ),
      ),
    );
  }
}
