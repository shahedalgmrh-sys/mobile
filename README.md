# Sahel / ساحل — Mobile App (Flutter)

تطبيق **Flutter** المخصص لمنصة خدمات ساحل (العميل + مقدم الخدمة فقط — واجهة الإدارة تبقى على الويب).

---

## 1. المتطلبات الأساسية (تثبيت Flutter SDK)

> ⚠️ Flutter SDK **غير مثبت حالياً على الجهاز**. قم بالتثبيت أولاً بالخطوات التالية:

### على Windows:
1. حمل Flutter SDK (Stable) من:  
   https://docs.flutter.dev/get-started/install/windows
2. استخراج الأرشيف إلى مسار ثابت مثل: `C:\src\flutter`
3. أضف `C:\src\flutter\bin` إلى **System PATH** (بيانات النظام المتقدمة → متغيرات البيئة).
4. افتح **Terminal جديد** و شغّل:
   ```bash
   flutter doctor
   ```
5. أكمل التبعيات المطلوبة:
   ```bash
   flutter doctor --android-licenses
   ```
   واتبع التعليمات لتثبيت Android Studio (للـ Android SDK Platform / Build Tools).

---

## 2. أول تشغيل للمشروع

```bash
cd e:\saber\mobile

# 1. تنزيل التبعيات
flutter pub get

# 2. توليد الملفات التلقائية (Drift, Retrofit, json_serializable, freezed)
dart run build_runner build --delete-conflicting-outputs

# 3. فحص static analysis
dart analyze

# 4. تشغيل التطبيق على محاكي أو جهاز (عميل)
flutter run -t lib/main_customer.dart

# 5. تشغيل نسخة مقدم الخدمة
flutter run -t lib/main_provider.dart
```

> **ملاحظة**: إذا أردت بناء release:
> ```bash
> flutter build apk --flavor customer -t lib/main_customer.dart
> flutter build apk --flavor provider -t lib/main_provider.dart
> ```

---

## 3. الربط مع الباك-إند (Laravel)

السيرفر المحلي يعمل حالياً على `http://127.0.0.1:8000`.

| الملف | المكان | قيمة base URL |
|-------|--------|---------------|
| AppConfig | [app/config/app_config.dart](lib/app/config/app_config.dart) | `http://127.0.0.1:8000/api/mobile` |

### ⚠️ مهم جداً — مسارات `/api/mobile/*`

مجموعة الـ routes الجديدة **لم تُضاف بعد** إلى Laravel. قبل إجراء أي استدعاء API من الموبايل، قم بإضافة هذا الـ group إلى `e:\saber\saber\routes\api.php`:

```php
use App\Http\Middleware\EnsureCustomer;
use App\Http\Middleware\EnsureProvider;
use Illuminate\Support\Facades\Route;

/* ===========================================================
   Mobile API v1 — Prefix: /api/mobile
   =========================================================== */
Route::prefix('mobile')->group(static function () {

    Route::middleware(['throttle:90,1'])->group(static function () {
        // 1. Auth (No Sanctum)
        Route::post('/auth/login', [MobileAuthController::class, 'login']);
        Route::post('/auth/verify-otp', [MobileAuthController::class, 'verifyOtp']);
        Route::post('/auth/register', [MobileAuthController::class, 'register']);
        Route::post('/auth/refresh', [MobileAuthController::class, 'refresh']);
    });

    // ----- Sanctum protected -----
    Route::middleware(['auth:sanctum', 'abilities:*', 'throttle:120,1'])->group(static function () {

        Route::post('/auth/logout', [MobileAuthController::class, 'logout']);
        Route::get('/me', [MobileAuthController::class, 'me']);
        Route::post('/me/profile-setup', [MobileAuthController::class, 'profileSetup']);

        // --- Customer ---
        Route::middleware(EnsureCustomer::class)->prefix('c')->group(static function () {
            Route::get('/home', [MobileCustomerController::class, 'home']);
            Route::get('/search', [MobileCustomerController::class, 'search']);
            Route::get('/services/{slug}', [MobileCustomerController::class, 'serviceDetails']);
            Route::get('/providers/{id}', [MobileCustomerController::class, 'providerProfile']);

            Route::get('/bookings', [MobileBookingController::class, 'indexCustomer']);
            Route::post('/bookings', [MobileBookingController::class, 'createBooking']);
            Route::get('/bookings/{id}', [MobileBookingController::class, 'showCustomer']);
            Route::post('/bookings/{id}/cancel', [MobileBookingController::class, 'cancelBooking']);
            Route::get('/bookings/{id}/track', [MobileBookingController::class, 'trackCustomer']);

            Route::post('/reviews', [MobileCustomerController::class, 'submitReview']);
            Route::post('/complaints', [MobileCustomerController::class, 'submitComplaint']);
            Route::get('/favorites', [MobileCustomerController::class, 'favoritesIndex']);
            Route::post('/favorites/{providerId}', [MobileCustomerController::class, 'toggleFavorite']);
            Route::get('/wallet', [MobileCustomerController::class, 'walletIndex']);
            Route::get('/notifications', [MobileNotificationController::class, 'index']);
            Route::get('/chat/threads', [MobileChatController::class, 'threadsIndex']);
            Route::get('/chat/threads/{id}/messages', [MobileChatController::class, 'threadMessages']);
            Route::post('/chat/threads/{id}/messages', [MobileChatController::class, 'sendMessage']);
            Route::get('/addresses', [MobileCustomerController::class, 'addressesIndex']);
        });

        // --- Provider ---
        Route::middleware(EnsureProvider::class)->prefix('p')->group(static function () {
            Route::get('/dashboard', [MobileProviderController::class, 'dashboard']);
            Route::get('/requests', [MobileProviderBookingController::class, 'requestsFeed']);
            Route::post('/bookings/{id}/accept', [MobileProviderBookingController::class, 'accept']);
            Route::post('/bookings/{id}/reject', [MobileProviderBookingController::class, 'reject']);
            Route::post('/bookings/{id}/start', [MobileProviderBookingController::class, 'start']);
            Route::post('/bookings/{id}/complete', [MobileProviderBookingController::class, 'complete']);
            Route::post('/bookings/{id}/upload-proof', [MobileProviderBookingController::class, 'uploadWorkProof']);

            Route::get('/bookings', [MobileProviderBookingController::class, 'indexProvider']);
            Route::get('/bookings/{id}', [MobileProviderBookingController::class, 'showProvider']);

            Route::get('/earnings', [MobileProviderController::class, 'earningsIndex']);
            Route::post('/withdraw', [MobileProviderController::class, 'requestWithdraw']);
            Route::get('/services', [MobileProviderController::class, 'servicesCatalog']);
            Route::post('/services/{id}/toggle', [MobileProviderController::class, 'toggleServiceActive']);
            Route::get('/kyc', [MobileProviderController::class, 'kycStatus']);
            Route::post('/kyc/{step}/submit', [MobileProviderController::class, 'submitKycStep']);
            Route::get('/calendar', [MobileProviderController::class, 'calendarIndex']);
            Route::get('/inbox/threads', [MobileChatController::class, 'providerThreads']);
            Route::get('/notifications', [MobileNotificationController::class, 'providerIndex']);
        });
    });
});
```

ثم قم بإنشاء الـ Controllers المذكورة أعلاه وربطها بـ **Service Classes** الموجودة حالياً في `app/Modules/` (لا تكتب أي منطق تجاري داخل Controllers).

---

## 4. الـ Flavors (نسخ التطبيق)

| Entry Point | الدور | AppFlavor |
|---|---|---|
| `lib/main_customer.dart` | العميل | `AppFlavor.customer` |
| `lib/main_provider.dart` | مقدم الخدمة | `AppFlavor.provider` |
| `lib/main.dart` | افتراضي (اختبار) | `AppFlavor.customer` |

---

## 5. الـ Custom Headers (الـ 6 headers المطلوبة في المواصفات)

يتم ضخهم تلقائياً من داخل [api_client.dart](lib/core/network/api_client.dart):
```
Accept-Language   → ar / en
X-Currency        → yer / sar / usd
X-Device-ID       → UUID (Secure Storage)
X-App-Version     → 1.0.0
X-Client-Type     → customer-app / provider-app
Authorization     → Bearer {sanctum_token}
```

---

## 6. هيكل الكود (109 ملفات Dart + 27 مجلد)

```
lib/
├─ main.dart / main_customer.dart / main_provider.dart
├─ app/
│  ├─ config/app_config.dart                    # AppFlavor + apiBaseUrl
│  ├─ router/app_router.dart                    # GoRouter + Auth Guard + 74 Route
│  ├─ theme/{sahel_colors, sahel_theme}.dart    # 6 ألوان + 5 elevations + 4 radii + 7 button variants
│  └─ sahel_app.dart                            # MaterialApp.router + Theme
├─ core/
│  ├─ constants/{api_endpoints, app_headers, enums}.dart
│  ├─ network/api_client.dart                   # Dio Interceptor → 401, 422, 500 Failures
│  ├─ storage/{secure_storage, offline_db}.dart # SecureStorage + Drift Schema
│  └─ errors/failures.dart                      # Sealed Failure subtypes
├─ data/
│  ├─ models/{user, booking, service, provider, review, wallet, chat, complaint}_model.dart
│  └─ repositories/i_{auth, booking, service, wallet}_repository.dart
├─ shared/widgets/
│    ├─ sahel_button.dart         # 7 variants: filled / gradient / soft / outline / ghost / danger / amber
│    ├─ status_pill.dart / booking_status_pill.dart
│    ├─ booking_stepper.dart / booking_status_stepper.dart
│    ├─ service_card.dart / provider_mini_card.dart / review_card.dart
│    ├─ shimmer_card.dart / empty_state.dart / category_tile.dart / sahel_bottom_nav_item.dart
├─ modules/auth/screens/         # splash, onboarding, language, login, otp, register, profile_setup
├─ modules/customer/screens/     # 43 شاشة (home, search, bookings wizard + stepper + tracking, wallet, notifications, ...)
└─ modules/provider/screens/     # 31 شاشة (dashboard, requests accept/reject, earnings+withdraw, KYC 4-step, calendar, ...)
```

---

## 7. الاختبارات الجاهزة للتنفيذ بعد تثبيت Flutter

| الخطوة | الأمر |
|---|---|
| 🔷 تنزيل التبعيات | `flutter pub get` |
| 🔷 توليد ملفات `.g.dart` | `dart run build_runner build --delete-conflicting-outputs` |
| 🔷 فحص الأخطاء | `dart analyze` |
| 🔷 تشغيل الاختبارات | `flutter test` |
| 🔷 تشغيل التطبيق (عميل) | `flutter run -t lib/main_customer.dart` |
| 🔷 تشغيل التطبيق (مقدم خدمات) | `flutter run -t lib/main_provider.dart` |

---

## 8. البندات المعلقة للمطور القادم

- [ ] **Android flavors**: إضافة `productFlavors { customer / provider }` داخل `android/app/build.gradle` مع `applicationIdSuffix`.
- [ ] **iOS Schemes**: إنشاء Schemes منفصلة (Customer / Provider) مع Bundle IDs مختلفة في Xcode.
- [ ] **Network Security Config**: السماح لـ cleartext HTTP لأجل `10.0.2.2` و `127.0.0.1:8000` أثناء التطوير (ملف `network_security_config.xml`).
- [ ] **Concrete Repository implementations**: كتابة الـ Classes الفعلية التي تنفذ `IAuthRepository`, `IBookingRepository`, ... وتربط Dio + SecureStorage + Drift.
- [ ] **Riverpod Notifier binding**: استبدال الـ placeholder lists داخل الشاشات بـ `ref.watch(...)` مع `AsyncValue` (loading → shimmer, data, error).
- [ ] **FCM setup**: ربط ملفات `google-services.json` + `GoogleService-Info.plist` لكل Flavor.
- [ ] **Laravel Mobile Routes**: تنفيذ الـ Route group أعلاه (الفقرة 3) + Controllers داخل الباك-إند.

---

## 9. بيانات الاعتماد للتجربة

| الدور | البريد | كلمة المرور |
|---|---|---|
| Admin (web فقط) | `admin@sahel.com` | `Password123!` |
| Provider | `provider@sahel.com` | `Password123!` |
| Customer | `customer@sahel.com` | `Password123!` |

Web: http://127.0.0.1:8000  
Mobile API (مستقبلاً): http://127.0.0.1:8000/api/mobile
