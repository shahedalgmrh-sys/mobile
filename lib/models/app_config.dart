import 'booking_status.dart';

class AppConfig {
  final String appName;
  final UserRole initialRole;
  final String environment;

  const AppConfig({
    required this.appName,
    required this.initialRole,
    this.environment = 'production',
  });

  factory AppConfig.customer() => const AppConfig(
        appName: 'Sahel',
        initialRole: UserRole.customer,
      );

  factory AppConfig.provider() => const AppConfig(
        appName: 'Sahel Provider',
        initialRole: UserRole.provider,
      );
}
