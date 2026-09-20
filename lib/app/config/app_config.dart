enum AppFlavor { customer, provider }

class AppConfig {
  final AppFlavor flavor;
  final String apiBaseUrl;
  final String appName;
  final String appTitle;
  final String deviceId;
  final String appVersion;

  const AppConfig({
    required this.flavor,
    this.apiBaseUrl = 'http://127.0.0.1:8000/api/mobile',
    required this.appName,
    required this.appTitle,
    required this.deviceId,
    this.appVersion = '1.0.0+421',
  });

  bool get isCustomer => flavor == AppFlavor.customer;
  bool get isProvider => flavor == AppFlavor.provider;

  AppConfig copyWith({
    AppFlavor? flavor,
    String? apiBaseUrl,
    String? appName,
    String? appTitle,
    String? deviceId,
    String? appVersion,
  }) {
    return AppConfig(
      flavor: flavor ?? this.flavor,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      appName: appName ?? this.appName,
      appTitle: appTitle ?? this.appTitle,
      deviceId: deviceId ?? this.deviceId,
      appVersion: appVersion ?? this.appVersion,
    );
  }

  @override
  String toString() {
    return 'AppConfig(flavor: $flavor, apiBaseUrl: $apiBaseUrl, '
        'appName: $appName, appTitle: $appTitle, deviceId: $deviceId, '
        'appVersion: $appVersion)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppConfig &&
        other.flavor == flavor &&
        other.apiBaseUrl == apiBaseUrl &&
        other.appName == appName &&
        other.appTitle == appTitle &&
        other.deviceId == deviceId &&
        other.appVersion == appVersion;
  }

  @override
  int get hashCode {
    return Object.hash(
      flavor,
      apiBaseUrl,
      appName,
      appTitle,
      deviceId,
      appVersion,
    );
  }
}
