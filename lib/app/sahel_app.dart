import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../models/app_config.dart';
import '../providers/settings_provider.dart';
import '../shared/theme/sahel_theme.dart';
import 'router/app_router.dart';

class SahelApp extends ConsumerWidget {
  final AppConfig config;

  const SahelApp({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final language = ref.watch(appSettingsProvider).language;
    return MaterialApp.router(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      locale: Locale(language),
      themeMode: ThemeMode.light,
      theme: SahelTheme.light,
      darkTheme: SahelTheme.dark,
    );
  }
}
