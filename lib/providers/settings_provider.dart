import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final String language;
  final String currency;

  const AppSettings({this.language = 'ar', this.currency = 'yer'});

  AppSettings copyWith({String? language, String? currency}) => AppSettings(
        language: language ?? this.language,
        currency: currency ?? this.currency,
      );
}

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  static const _kLang = 'app_language';
  static const _kCurrency = 'app_currency';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      language: prefs.getString(_kLang) ?? 'ar',
      currency: prefs.getString(_kCurrency) ?? 'yer',
    );
  }

  Future<void> setLanguage(String language) async {
    state = state.copyWith(language: language);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLang, language);
  }

  Future<void> setCurrency(String currency) async {
    state = state.copyWith(currency: currency);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCurrency, currency);
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier(),
);
