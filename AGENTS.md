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
- Backend API: `E:\saber\SaberWeb-latest` (Laravel). Base prefixes:
  `/api` public, `/api/auth`, `/api/customer`, `/api/provider`. Response envelope
  `{status, message, data}` — unwrapped via `apiData()` in `parsers.dart`.
- There is NO public service-detail endpoint — `ServiceDetailsScreen` receives a
  `Service` via `GoRouterState.extra`, falling back to the services list by slug/id.

## Theme
- Single source of truth: `lib/app/theme/` (colors/radii/elevations/theme).
- `lib/shared/theme/` and `lib/sahel_theme/` are 1-line re-export shims — do NOT
  edit them; edit `app/theme` and they follow. Do not duplicate values.

## Wallet top-up (FIN-01 safe)
Server contract: `SaberWeb-latest/app/Http/Controllers/Api/CustomerApiController.php`
+ `PaymentService::confirmWalletTopUp`:
1. `POST /customer/wallet/add-funds {amount (10–50000), payment_method}` → 201
   `status: pending` with `payment_id` + `checkout_url` (Blade gateway page).
2. Payment completes via the gateway callback (`checkout_url` — opened
   externally via url_launcher from `WalletScreen`).
3. `POST /customer/wallet/confirm-payment/{paymentId}` → 200 (credits wallet,
   idempotent) · 503 when the gateway is not configured · 422 validation.
Never credit/assume funds before step 3 succeeds — the server enforces the
FIN-01 gate and the UI mirrors it (no silent mock confirm).

## Screens
- Both root-level screens in `modules/{customer,provider}/screens/*.dart` AND
  the grouped subfolders (`bookings/`, `home/`, `profile/`, …) are live and
  imported by the router. The earlier "root screens are dead legacy" note is
  obsolete after the 2026-10-12 cleanup (commit f137a14) — verify imports
  before deleting anything.
- `lib/models/` (plain DTOs: service/provider/review/booking_status) is used by
  widgets/screens; `lib/data/models/` (json_serializable models with `.g.dart`)
  is the API-facing layer. Both are live — unifying them is a future refactor,
  not a quick delete.
- `lib/main_provider.dart` is a legitimate dev run target that boots the app in
  the provider flavor (`flutter run -t lib/main_provider.dart`). The identical
  `main_customer.dart` duplicate was removed 2026-10-21.

## Gotchas
- API parity doc (`docs/API_PARITY_CHECK.md`) predates the 2026-10-19..21
  commits: `available-slots`, `customer/me/avatar`,
  `wallet/confirm-payment/{id}` and `provider/profile/password` are wired at
  repo and UI layers now. Still UI-unwired: `customer/payments/{id}`
  (repo method exists) and `provider/profile/{avatar|cover|logo}`.
- Do not edit `SaberWeb-main` (archive copy) — the reference backend is
  `SaberWeb-latest`.
- `BookingStatus.paid` exists — keep status switches exhaustive.
