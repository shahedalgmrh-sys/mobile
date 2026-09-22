# Sahel Mobile (Flutter) — Agent Notes

## Toolchain
- Flutter SDK: `C:\flutter-sdk\flutter` (Flutter 3.47.5 / Dart 3.13.4) — extracted from `flutter_windows_3.47.5-stable.zip` in this folder.
- pubspec requires Dart `>=3.13.3 <4.0.0`, Flutter `>=3.47.4`. Do NOT use the older `C:\src\flutter` (3.22.2).
- Android: AGP 8.11.1, Kotlin 2.2.20, Gradle 8.14 (`android/gradle/wrapper/gradle-wrapper.properties`).
  `coreLibraryDesugaring` enabled in `app/build.gradle` (required by flutter_local_notifications).
  `uni_links` was removed (dead dependency, breaks AGP 8 namespace checks).
  `kotlin.incremental=false` in `gradle.properties` — required because pub-cache sources
  live on `C:` while the project is on `E:` (Kotlin incremental cache cannot span drives).
- First debug build auto-installs Android NDK 28 + CMake 3.22.1 and takes ~40 min
  (non-incremental plugin compilation); subsequent builds are much faster.
  Verified: `flutter build apk --debug` → `build/app/outputs/flutter-apk/app-debug.apk`.

## Commands
- `C:/flutter-sdk/flutter/bin/flutter.bat pub get`
- `C:/flutter-sdk/flutter/bin/flutter.bat analyze`
- `C:/flutter-sdk/flutter/bin/flutter.bat test`
- `C:/flutter-sdk/flutter/bin/flutter.bat build apk --debug [--android-skip-build-dependency-validation]`
- Override API base URL: `--dart-define=API_BASE_URL=http://<host>:8000/api`
  (default `http://10.0.2.2:8000/api` = Android emulator → host machine).

## Architecture
- API layer: `lib/core/network/api_client.dart` (Dio + token/locale/currency headers),
  `lib/core/constants/api_endpoints.dart`, `lib/data/sources/remote_sources.dart`,
  `lib/data/repositories/{auth,catalog,customer,provider}_repository.dart`,
  defensive snake_case parsers in `lib/data/repositories/parsers.dart`.
- State: Riverpod 2 — `lib/core/providers.dart` (DI graph),
  `lib/providers/auth_provider.dart` (`authNotifierProvider`),
  `lib/providers/data_providers.dart`, `lib/providers/settings_provider.dart`
  (language/currency persisted → sent as `Accept-Language`/`X-Currency` headers).
- Router: `lib/app/router/app_router.dart` — role-aware redirects
  (customer → `/home`, provider → `/p/dashboard`).
- Backend API: `E:\saber\SaberWeb-main\SaberWeb-main` (Laravel). Base prefixes:
  `/api` public, `/api/auth`, `/api/customer`, `/api/provider`. Response envelope
  `{status, message, data}` — unwrapped via `apiData()` in `parsers.dart`.
- There is NO public service-detail endpoint — `ServiceDetailsScreen` receives a
  `Service` via `GoRouterState.extra`, falling back to the services list by slug/id.

## Gotchas
- Duplicate legacy screens exist at `lib/modules/*/screens/*.dart` root level —
  they are unimported dead code; the router uses the `*/screens/<subdir>/` versions.
- Do not edit `SaberWeb-main` (backend/website) — mobile-only scope.
- `BookingStatus.paid` exists — keep status switches exhaustive.
