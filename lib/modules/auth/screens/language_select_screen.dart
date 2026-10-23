import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';
import 'package:saber_flutter/shared/widgets/sahel_auth_header.dart';
import 'package:saber_flutter/shared/widgets/sahel_button.dart';

class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  String? _selectedLang;

  @override
  Widget build(BuildContext context) {
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'اختر اللغة',
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        color: SahelColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Choose your language',
                      style: SahelTextStyles.caption,
                    ),
                    const SizedBox(height: 28),
                    _LanguageCard(
                      flag: '🇾🇪',
                      title: 'العربية',
                      subtitle: 'اليمن — ريال يمني · صنعاء',
                      selected: _selectedLang == 'ar',
                      onTap: () => setState(() => _selectedLang = 'ar'),
                    ),
                    const SizedBox(height: 14),
                    _LanguageCard(
                      flag: '🇸🇦',
                      title: 'English',
                      subtitle: 'KSA — SAR · Riyadh',
                      selected: _selectedLang == 'en',
                      onTap: () => setState(() => _selectedLang = 'en'),
                    ),
                    const Spacer(),
                    SahelButton.gradient(
                      label: 'تأكيد / Confirm',
                      height: 52,
                      onPressed: _selectedLang == null
                          ? null
                          : () => context.go('/login'),
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

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: SahelRadii.mdRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? SahelColors.primarySurface : SahelColors.surface,
          borderRadius: SahelRadii.mdRadius,
          border: Border.all(
            color: selected ? SahelColors.primary : SahelColors.border,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: SahelElevations.xs,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 38)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: SahelColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: SahelColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? SahelColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? SahelColors.primary
                      : SahelColors.borderStrong,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 16, color: SahelColors.onPrimary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
