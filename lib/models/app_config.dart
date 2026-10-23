import '../core/constants/enums.dart';

/// Unified app configuration — single source of truth.
/// One AppConfig per flavor (customer / provider).
class AppConfig {
  final String appName;
  final UserRole initialRole;
  final String environment;
  final String apiBaseUrl;
  final String appVersion;

  /// Google Maps SDK key. Supplied at build time via
  /// `--dart-define=GOOGLE_MAPS_API_KEY=…` (also forwarded to the Android
  /// manifest meta-data through the Gradle placeholder). When empty the
  /// tracking screen falls back to the informative placeholder map.
  final String googleMapsApiKey;

  const AppConfig({
    required this.appName,
    required this.initialRole,
    this.environment = 'production',
    this.apiBaseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      // Android emulator → host machine; override for real devices/servers.
      defaultValue: 'http://10.0.2.2:8000/api',
    ),
    this.appVersion = '1.0.0+421',
    this.googleMapsApiKey = const String.fromEnvironment(
      'GOOGLE_MAPS_API_KEY',
      defaultValue: '',
    ),
  });

  bool get isCustomer => initialRole == UserRole.customer;
  bool get isProvider => initialRole == UserRole.provider;

  factory AppConfig.customer() => const AppConfig(
        appName: 'Sahel',
        initialRole: UserRole.customer,
      );

  factory AppConfig.provider() => const AppConfig(
        appName: 'Sahel Provider',
        initialRole: UserRole.provider,
      );
}
