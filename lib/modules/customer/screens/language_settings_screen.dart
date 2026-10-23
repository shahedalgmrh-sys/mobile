import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saber_flutter/providers/settings_provider.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(appSettingsProvider).language;

    return Scaffold(
      appBar: AppBar(title: const Text('اللغة')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _opt(ref, selected, 'ar', 'العربية', 'اليمن / السعودية / الإمارات'),
            const SizedBox(height: 10),
            _opt(ref, selected, 'en', 'English', 'International English'),
          ],
        ),
      ),
    );
  }

  Widget _opt(
      WidgetRef ref, String selected, String code, String t, String sub) {
    final isSelected = selected == code;
    return GestureDetector(
      onTap: () => ref.read(appSettingsProvider.notifier).setLanguage(code),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SahelColors.onPrimary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isSelected
                  ? SahelColors.primary500
                  : SahelColors.slate200,
              width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: const TextStyle(
                          color: SahelColors.muted, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              const CircleAvatar(
                  radius: 12,
                  backgroundColor: SahelColors.primary500,
                  child: Icon(Icons.check, size: 16, color: SahelColors.onPrimary))
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: SahelColors.slate300, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
