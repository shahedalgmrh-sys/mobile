import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:saber_flutter/app/theme/sahel_colors.dart';

class SahelRadii {
  SahelRadii._();
  static const double sm = 10.5;
  static const double md = 16;
  static const double lg = 24;
  static const double pill = 999;
  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get pillRadius => BorderRadius.circular(pill);
}

/// 8px base grid with a 4px sub-unit, mirroring the design system spacing
/// scale so every screen shares identical rhythm.
class SahelSpacing {
  SahelSpacing._();
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
  static const double section = 40;
  static const double screen = 16;

  static const EdgeInsets screenPadding = EdgeInsets.all(screen);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets gutter = EdgeInsets.symmetric(horizontal: screen);
}

/// Named text roles from the design system. Prefer these over ad-hoc
/// `TextStyle` instances so weight/size stay consistent across screens.
class SahelTextStyles {
  SahelTextStyles._();

  static const TextStyle eyebrow = TextStyle(
    fontSize: 12.5,
    height: 1.0,
    fontWeight: FontWeight.w700,
    // Arabic is cursive: tracking must stay at 0 to preserve ligatures.
    letterSpacing: 0,
    color: SahelColors.primary700,
  );

  static const TextStyle titleCard = TextStyle(
    fontSize: 18,
    height: 1.38,
    fontWeight: FontWeight.w700,
    color: SahelColors.text,
  );

  static const TextStyle headlineSm = TextStyle(
    fontSize: 20,
    height: 1.4,
    fontWeight: FontWeight.w700,
    color: SahelColors.text,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: SahelColors.text,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: SahelColors.textMuted,
  );

  static const TextStyle price = TextStyle(
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w800,
    color: SahelColors.text,
  );
}

class SahelElevations {
  SahelElevations._();
  static const List<BoxShadow> xs = [
    BoxShadow(color: Color(0x0A0F172A), blurRadius: 4, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0F0F172A), blurRadius: 8, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x140F172A), blurRadius: 16, offset: Offset(0, 4)),
  ];
  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x1A0F172A), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> glow = [
    BoxShadow(color: Color(0x330D9488), blurRadius: 32, offset: Offset(0, 8)),
  ];
}

class SahelTheme {
  SahelTheme._();

  static ColorScheme get colorSchemeLight => const ColorScheme.light(
        primary: SahelColors.primary,
        primaryContainer: SahelColors.primary100,
        secondary: SahelColors.amber,
        surface: SahelColors.surface,
        onPrimary: Color(0xFFFFFFFF),
        onSecondary: SahelColors.text,
        onSurface: SahelColors.text,
        error: SahelColors.danger,
        onError: Color(0xFFFFFFFF),
        onPrimaryContainer: SahelColors.primary700,
        onSurfaceVariant: SahelColors.textMuted,
        surfaceContainerHighest: SahelColors.surface3,
        outline: SahelColors.border,
      );

  static ColorScheme get colorSchemeDark => const ColorScheme.dark(
        primary: SahelColors.primary300,
        primaryContainer: SahelColors.primary800,
        secondary: SahelColors.amber,
        surface: Color(0xFF1E293B),
        onPrimary: Color(0xFF0F172A),
        onSecondary: Color(0xFF0F172A),
        onSurface: Color(0xFFF1F5F9),
        error: Color(0xFFEF4444),
        onError: Color(0xFF0F172A),
        onPrimaryContainer: SahelColors.primary100,
        onSurfaceVariant: Color(0xFF94A3B8),
        surfaceContainerHighest: Color(0xFF334155),
        outline: Color(0xFF475569),
      );

  static TextTheme get sahelTextTheme {
    final tajawal = GoogleFonts.tajawalTextTheme();
    return TextTheme(
      displayLarge: tajawal.displayLarge?.copyWith(
        fontFamily: GoogleFonts.tajawal().fontFamily,
        fontFamilyFallback: [GoogleFonts.plusJakartaSans().fontFamily ?? 'PlusJakartaSans'],
      ),
      displayMedium: tajawal.displayMedium?.copyWith(
        fontFamily: GoogleFonts.tajawal().fontFamily,
        fontFamilyFallback: [GoogleFonts.plusJakartaSans().fontFamily ?? 'PlusJakartaSans'],
      ),
      displaySmall: tajawal.displaySmall?.copyWith(
        fontFamily: GoogleFonts.tajawal().fontFamily,
        fontFamilyFallback: [GoogleFonts.plusJakartaSans().fontFamily ?? 'PlusJakartaSans'],
      ),
      headlineLarge: tajawal.headlineLarge?.copyWith(
        fontFamily: GoogleFonts.tajawal().fontFamily,
        fontFamilyFallback: [GoogleFonts.plusJakartaSans().fontFamily ?? 'PlusJakartaSans'],
      ),
      headlineMedium: tajawal.headlineMedium?.copyWith(
        fontFamily: GoogleFonts.tajawal().fontFamily,
        fontFamilyFallback: [GoogleFonts.plusJakartaSans().fontFamily ?? 'PlusJakartaSans'],
      ),
      headlineSmall: tajawal.headlineSmall?.copyWith(
        fontFamily: GoogleFonts.tajawal().fontFamily,
        fontFamilyFallback: [GoogleFonts.plusJakartaSans().fontFamily ?? 'PlusJakartaSans'],
      ),
      titleLarge: tajawal.titleLarge?.copyWith(
        fontFamily: GoogleFonts.tajawal().fontFamily,
        fontFamilyFallback: [GoogleFonts.plusJakartaSans().fontFamily ?? 'PlusJakartaSans'],
      ),
      titleMedium: tajawal.titleMedium?.copyWith(
        fontFamily: GoogleFonts.tajawal().fontFamily,
        fontFamilyFallback: [GoogleFonts.plusJakartaSans().fontFamily ?? 'PlusJakartaSans'],
      ),
      titleSmall: tajawal.titleSmall?.copyWith(
        fontFamily: GoogleFonts.tajawal().fontFamily,
        fontFamilyFallback: [GoogleFonts.plusJakartaSans().fontFamily ?? 'PlusJakartaSans'],
      ),
      bodyLarge: tajawal.bodyLarge?.copyWith(
        fontFamily: GoogleFonts.tajawal().fontFamily,
        fontFamilyFallback: [GoogleFonts.plusJakartaSans().fontFamily ?? 'PlusJakartaSans'],
      ),
      bodyMedium: tajawal.bodyMedium?.copyWith(
        fontFamily: GoogleFonts.tajawal().fontFamily,
        fontFamilyFallback: [GoogleFonts.plusJakartaSans().fontFamily ?? 'PlusJakartaSans'],
      ),
      bodySmall: tajawal.bodySmall?.copyWith(
        fontFamily: GoogleFonts.tajawal().fontFamily,
        fontFamilyFallback: [GoogleFonts.plusJakartaSans().fontFamily ?? 'PlusJakartaSans'],
      ),
      labelLarge: tajawal.labelLarge?.copyWith(
        fontFamily: GoogleFonts.tajawal().fontFamily,
        fontFamilyFallback: [GoogleFonts.plusJakartaSans().fontFamily ?? 'PlusJakartaSans'],
      ),
      labelMedium: tajawal.labelMedium?.copyWith(
        fontFamily: GoogleFonts.tajawal().fontFamily,
        fontFamilyFallback: [GoogleFonts.plusJakartaSans().fontFamily ?? 'PlusJakartaSans'],
      ),
      labelSmall: tajawal.labelSmall?.copyWith(
        fontFamily: GoogleFonts.tajawal().fontFamily,
        fontFamilyFallback: [GoogleFonts.plusJakartaSans().fontFamily ?? 'PlusJakartaSans'],
      ),
    );
  }

  static ButtonStyle get primaryFilled => ElevatedButton.styleFrom(
        backgroundColor: SahelColors.primary,
        foregroundColor: const Color(0xFFFFFFFF),
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: SahelRadii.smRadius),
        elevation: 0,
      );

  static ButtonStyle get gradient => ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: SahelRadii.smRadius),
      );

  static ButtonStyle get soft => ElevatedButton.styleFrom(
        backgroundColor: SahelColors.primary100,
        foregroundColor: SahelColors.primary700,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: SahelRadii.smRadius),
        elevation: 0,
      );

  static ButtonStyle get outline => OutlinedButton.styleFrom(
        foregroundColor: SahelColors.primary,
        side: const BorderSide(color: SahelColors.primary, width: 1.5),
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: SahelRadii.smRadius),
      );

  static ButtonStyle get ghost => TextButton.styleFrom(
        foregroundColor: SahelColors.primary,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: SahelRadii.smRadius),
      );

  static ButtonStyle get danger => ElevatedButton.styleFrom(
        backgroundColor: SahelColors.danger,
        foregroundColor: const Color(0xFFFFFFFF),
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: SahelRadii.smRadius),
        elevation: 0,
      );

  static ButtonStyle get amber => ElevatedButton.styleFrom(
        backgroundColor: SahelColors.amber,
        foregroundColor: SahelColors.text,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: SahelRadii.smRadius),
        elevation: 0,
      );

  static BadgeThemeData get badgeTheme => const BadgeThemeData(
        backgroundColor: SahelColors.primary,
        smallSize: 8,
        largeSize: 18,
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        textStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFFFFFF),
        ),
      );

  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
        filled: true,
        fillColor: SahelColors.surface2,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: SahelRadii.smRadius,
          borderSide: const BorderSide(color: SahelColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: SahelRadii.smRadius,
          borderSide: const BorderSide(color: SahelColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: SahelRadii.smRadius,
          borderSide:
              const BorderSide(color: SahelColors.primary400, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: SahelRadii.smRadius,
          borderSide: const BorderSide(color: SahelColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: SahelRadii.smRadius,
          borderSide:
              const BorderSide(color: SahelColors.danger, width: 1.5),
        ),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          color: SahelColors.textMuted,
        ),
        hintStyle: const TextStyle(color: SahelColors.textMuted),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: colorSchemeLight,
        textTheme: sahelTextTheme.apply(
          bodyColor: SahelColors.text,
          displayColor: SahelColors.text,
        ),
        scaffoldBackgroundColor: SahelColors.bg,
        elevatedButtonTheme: ElevatedButtonThemeData(style: primaryFilled),
        outlinedButtonTheme: OutlinedButtonThemeData(style: outline),
        textButtonTheme: TextButtonThemeData(style: ghost),
        inputDecorationTheme: inputDecorationTheme,
        badgeTheme: badgeTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: SahelColors.surface,
          foregroundColor: SahelColors.text,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: sahelTextTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: SahelColors.text,
          ),
        ),
        cardTheme: CardThemeData(
          color: SahelColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: SahelRadii.mdRadius,
            side: const BorderSide(color: SahelColors.border),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        dividerTheme: const DividerThemeData(
          color: SahelColors.border,
          thickness: 1,
          space: 1,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: SahelColors.surface,
          indicatorColor: SahelColors.primary100,
          height: 72,
          labelTextStyle: WidgetStatePropertyAll(
            sahelTextTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: colorSchemeDark,
        textTheme: sahelTextTheme.apply(
          bodyColor: const Color(0xFFF1F5F9),
          displayColor: const Color(0xFFF1F5F9),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: SahelColors.primary300,
            foregroundColor: const Color(0xFF0F172A),
            minimumSize: const Size(0, 52),
            shape: RoundedRectangleBorder(borderRadius: SahelRadii.smRadius),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: SahelColors.primary300,
            side: const BorderSide(
                color: SahelColors.primary300, width: 1.5),
            minimumSize: const Size(0, 52),
            shape: RoundedRectangleBorder(borderRadius: SahelRadii.smRadius),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: SahelColors.primary300,
            minimumSize: const Size(0, 52),
            shape: RoundedRectangleBorder(borderRadius: SahelRadii.smRadius),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E293B),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: SahelRadii.smRadius,
            borderSide: const BorderSide(color: Color(0xFF334155)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: SahelRadii.smRadius,
            borderSide: const BorderSide(color: Color(0xFF334155)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: SahelRadii.smRadius,
            borderSide: const BorderSide(
                color: SahelColors.primary300, width: 1.5),
          ),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
          ),
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E293B),
          foregroundColor: const Color(0xFFF1F5F9),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: sahelTextTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF1F5F9),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: SahelRadii.mdRadius,
            side: const BorderSide(color: Color(0xFF334155)),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF334155),
          thickness: 1,
          space: 1,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF1E293B),
          indicatorColor: const Color(0x3314B8A6),
          height: 72,
          labelTextStyle: WidgetStatePropertyAll(
            sahelTextTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ),
      );
}

