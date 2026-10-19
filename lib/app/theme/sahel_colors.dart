import 'package:flutter/material.dart';

class SahelColors {
  const SahelColors._();

  // Primary Teal palette (#0D9488 base)
  static const Color primary50 = Color(0xFFF0FDFA);
  static const Color primary100 = Color(0xFFCCFBF1);
  static const Color primary200 = Color(0xFF99F6E4);
  static const Color primary300 = Color(0xFF5EEAD4);
  static const Color primary400 = Color(0xFF2DD4BF);
  static const Color primary500 = Color(0xFF14B8A6);
  static const Color primary = Color(0xFF0D9488);
  static const Color primary600 = Color(0xFF0F766E);
  static const Color primary700 = Color(0xFF115E59);
  static const Color primary800 = Color(0xFF134E4A);
  static const Color primary900 = Color(0xFF042F2E);

  // Containers (Material 3 roles mirrored from the design system)
  static const Color primaryContainer = Color(0xFFCCFBF1);
  static const Color secondaryContainer = Color(0xFF99EFE5);
  static const Color onSecondaryContainer = Color(0xFF006F67);
  static const Color tertiaryFixed = Color(0xFFFFDDB8);
  static const Color onTertiaryFixed = Color(0xFF2A1700);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // Amber palette (#F59E0B base)
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amberSoft = Color(0xFFFFF7E6);

  // Slate palette (#0F172A base)
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate = Color(0xFF475569);
  static const Color slate900 = Color(0xFF0F172A);

  // Semantic single colors
  static const Color green600 = Color(0xFF16A34A);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color emerald = Color(0xFF10B981);
  static const Color rose = Color(0xFFF43F5E);
  static const Color red400 = Color(0xFFF87171);
  static const Color red600 = Color(0xFFDC2626);

  // Surfaces (canvas → card → tinted insets, per the design system tiers)
  static const Color bg = Color(0xFFF6F7F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF8FAFC);
  static const Color surface3 = Color(0xFFF1F5F9);
  static const Color surfaceSubtle = Color(0xFFF8FAFC);
  static const Color surfaceInset = Color(0xFFF1F5F9);
  static const Color primarySurface = Color(0xFFF0FDFA);

  // Text
  static const Color text = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color muted = Color(0xFF64748B);
  static const Color textSoft = Color(0xFF94A3B8);

  // Border
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFFCBD5E1);

  // Communication channel (WhatsApp entry points only)
  static const Color whatsapp = Color(0xFF25D366);

  // Atmospheric focus halo per the design system (rgba(13,148,136,0.18))
  static const Color focusRing = Color(0x2E0D9488);

  // Status
  static const Color danger = Color(0xFFDC3545);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF0369A1);

  // Soft variants
  static const Color dangerSoft = Color(0xFFFEF2F2);
  static const Color successSoft = Color(0xFFECFDF5);
  static const Color warningSoft = Color(0xFFFFFBEB);
  static const Color violetSoft = Color(0xFFF5F3FF);
  static const Color infoSoft = Color(0xFFEFF6FF);
  static const Color shadowSm = Color(0x0A0F172A);

  // Gradients (used in hero banners)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF14B8A6),
      Color(0xFF0D9488),
      Color(0xFF0F766E),
    ],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF7E6),
      Color(0xFFF59E0B),
      Color(0xFFD97706),
    ],
  );

  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E293B),
      Color(0xFF0F172A),
      Color(0xFF020617),
    ],
  );
}
