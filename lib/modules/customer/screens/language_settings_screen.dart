import 'package:flutter/material.dart';
import '../../../shared/theme/sahel_colors.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selected = 'ar';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اللغة')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _opt('ar', '🇾🇪', 'العربية', 'اليمن / السعودية / الإمارات'),
            const SizedBox(height: 10),
            _opt('en', '🇬🇧', 'English', 'International English'),
          ],
        ),
      ),
    );
  }

  Widget _opt(String code, String flag, String t, String sub) {
    final selected = _selected == code;
    return GestureDetector(
      onTap: () => setState(() => _selected = code),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? SahelColors.primary500 : SahelColors.slate200,
              width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(sub, style: const TextStyle(color: SahelColors.muted, fontSize: 12)),
                ],
              ),
            ),
            if (selected)
              const CircleAvatar(radius: 12, backgroundColor: SahelColors.primary500,
                  child: Icon(Icons.check, size: 16, color: Colors.white))
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: SahelColors.slate300, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
