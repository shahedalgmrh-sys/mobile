import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/repositories/customer_repository.dart';
import '../data/repositories/provider_repository.dart';
import '../data/sources/remote_sources.dart';
import '../models/app_config.dart';
import '../providers/settings_provider.dart';
import 'network/api_client.dart';
import 'storage/secure_storage.dart';

/// Current app flavor config — overridden in main() via ProviderScope.
final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError('AppConfig must be overridden in main()'),
);

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

final dioProvider = Provider<Dio>((ref) => Dio());

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final settings = ref.read(appSettingsProvider);
  final client = ApiClient(
    dio: ref.watch(dioProvider),
    baseUrl: config.apiBaseUrl,
    appVersion: config.appVersion,
    storage: ref.watch(secureStorageProvider),
    language: settings.language,
    currency: settings.currency,
  );
  ref.listen(appSettingsProvider, (prev, next) {
    client.language = next.language;
    client.currency = next.currency;
  });
  return client;
});

/// Ensures a stable per-device UUID exists for the X-Device-ID header.
final deviceIdInitProvider = FutureProvider<String>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  var id = await storage.readDeviceId();
  if (id == null || id.isEmpty) {
    id = const Uuid().v4();
    await storage.writeDeviceId(id);
  }
  return id;
});

// ---------------------------------------------------------------------------
// Remote sources
// ---------------------------------------------------------------------------

final authRemoteSourceProvider = Provider<AuthRemoteSource>(
  (ref) => AuthRemoteSource(ref.watch(apiClientProvider)),
);

final catalogRemoteSourceProvider = Provider<CatalogRemoteSource>(
  (ref) => CatalogRemoteSource(ref.watch(apiClientProvider)),
);

final customerRemoteSourceProvider = Provider<CustomerRemoteSource>(
  (ref) => CustomerRemoteSource(ref.watch(apiClientProvider)),
);

final providerRemoteSourceProvider = Provider<ProviderRemoteSource>(
  (ref) => ProviderRemoteSource(ref.watch(apiClientProvider)),
);

// ---------------------------------------------------------------------------
// Repositories
// ---------------------------------------------------------------------------

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(authRemoteSourceProvider)),
);

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(ref.watch(catalogRemoteSourceProvider)),
);

final customerRepositoryProvider = Provider<CustomerRepository>(
  (ref) => CustomerRepository(ref.watch(customerRemoteSourceProvider)),
);

final providerRepositoryProvider = Provider<ProviderRepository>(
  (ref) => ProviderRepository(ref.watch(providerRemoteSourceProvider)),
);
