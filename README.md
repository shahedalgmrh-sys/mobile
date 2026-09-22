# ساحل / Sahel — تطبيق الموبايل (Flutter)

تطبيق Flutter لمنصة خدمات ساحل — يشمل دورَي **العميل** و**مقدم الخدمة** في تطبيق واحد
مع توجيه تلقائي حسب الدور بعد تسجيل الدخول.

---

## 1. المتطلبات

| الأداة | الإصدار المطلوب | ملاحظات |
|---|---|---|
| Flutter SDK | **3.47.5** (stable) أو `>=3.47.4` | يأتي معه Dart — لا حاجة لتثبيت Dart منفصلاً |
| Dart | `>=3.13.3 <4.0.0` | مدمج في Flutter |
| Android Studio | أي إصدار حديث | للـ Android SDK + Platform Tools + المحاكيات |
| PHP + Composer | PHP `>=8.2` | لتشغيل الـ Backend (Laravel 11) |
| Git | أي إصدار | لسحب المشروع |

> ⚠️ `pubspec.yaml` يفرض `Flutter >=3.47.4` — أي إصدار أقدم سيرفض `flutter pub get`.

### تثبيت Flutter (Windows)

1. حمّل النسخة: https://docs.flutter.dev/get-started/install/windows
   (أو استخدم الملف `flutter_windows_3.47.5-stable.zip` إذا توفر لديك)
2. فك الضغط في مسار ثابت مثل `C:\flutter-sdk\flutter`
3. أضف `C:\flutter-sdk\flutter\bin` إلى متغير البيئة `PATH`
4. افتح طرفية جديدة ونفّذ:

```bash
flutter doctor
flutter doctor --android-licenses
```

---

## 2. سحب المشروع وتشغيله

```bash
git clone https://github.com/shahedalgmrh-sys/mobile.git
cd mobile

# 1) تنزيل التبعيات
flutter pub get

# 2) فحص سريع
flutter analyze

# 3) تشغيل على جهاز/محاكي متصل
flutter run
```

أول بناء Android يستغرق ~30–40 دقيقة (ينزّل Android NDK 28 + CMake ويبني كل الإضافات) — طبيعي تماماً، البناءات التالية أسرع بكثير.

> الأدوات مضبوطة مسبقاً في المشروع: **AGP 8.11.1 · Kotlin 2.2.20 · Gradle 8.14**
> ولا تحتاج أي إعداد يدوي.

---

## 3. تشغيل الـ Backend (Laravel)

التطبيق يحتاج خادم الـ API ليعمل. مشروع الويب/الباك-إند في مستودع مستقل
(`SaberWeb-main` — Laravel 11 + Sanctum + SQLite افتراضياً):

```bash
cd <مسار-الباك-إند>

composer install
cp .env.example .env
php artisan key:generate

# إنشاء قاعدة SQLite وزرع البيانات التجريبية
type nul > database\database.sqlite     # Windows
php artisan migrate --seed --force

# التشغيل — مهم: 0.0.0.0 ليقبل اتصالات الأجهزة الأخرى
php artisan serve --host=0.0.0.0 --port=8000
```

تحقق أنه يعمل:

```bash
curl http://127.0.0.1:8000/api/health
# {"status":"ok","service":"sahel-home-services",...}
```

> ملاحظة: الـ seeder `LoadTestSeeder` يستخدم صيغة MySQL ويفشل على SQLite —
> هذا متوقع وغير مؤثر؛ كل البيانات الأساسية تُزرع قبله.

### حسابات تجريبية (بعد الـ seed)

| الدور | البريد | كلمة المرور |
|---|---|---|
| عميل | `customer@sahel.com` | `Password123!` |
| مقدم خدمة | `provider@sahel.com` | `Password123!` |
| عملاء إضافيون | `customer1@sahel.com` … `customer10@sahel.com` | `Password123!` |
| مزودون إضافيون | `provider1@sahel.com` … `provider10@sahel.com` | `Password123!` |

---

## 4. عنوان الـ API حسب بيئة التشغيل

يُمرَّر العنوان عبر `--dart-define=API_BASE_URL=...`:

| البيئة | القيمة |
|---|---|
| **محاكي Android** | `http://10.0.2.2:8000/api` (الافتراضي — لا حاجة لتمرير شيء) |
| **جهاز حقيقي عبر USB** | `http://127.0.0.1:8000/api` + أمر `adb reverse` (الأسفل) |
| **جهاز حقيقي عبر WiFi** | `http://<IP-الكمبيوتر>:8000/api` |

### الجهاز الحقيقي — أسهل طريقة (USB، بدون جدار حماية)

```bash
# مرة واحدة بعد وصل الجهاز
adb reverse tcp:8000 tcp:8000

# ثم شغّل
flutter run -d <device-id> --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

`adb reverse` يوجّه `localhost:8000` في الجوال إلى `localhost:8000` في الكمبيوتر
عبر كيبل USB — لا يحتاج WiFi ولا تعديل جدار الحماية.

### الجهاز الحقيقي عبر WiFi (نفس الشبكة)

```bash
# 1) اعرف IP الكمبيوتر: ipconfig → مثلاً 192.168.0.102
# 2) اسمح بالمنفذ في جدار Windows (PowerShell كمسؤول):
netsh advfirewall firewall add rule name="Laravel API 8000" dir=in action=allow protocol=TCP localport=8000

# 3) تحقق من متصفح الجوال: http://192.168.0.102:8000/api/health
# 4) شغّل
flutter run -d <device-id> --dart-define=API_BASE_URL=http://192.168.0.102:8000/api
```

### بناء APK للمشاركة

```bash
flutter build apk --debug --dart-define=API_BASE_URL=http://192.168.0.102:8000/api
# الناتج: build\app\outputs\flutter-apk\app-debug.apk
```

---

## 5. هيكل المشروع

```
lib/
├─ main.dart                       # نقطة الدخول (توجيه حسب الدور)
├─ app/
│  ├─ router/app_router.dart       # GoRouter + حارس المصادقة + توجيه الدور
│  ├─ theme/                       # الثيم والألوان
│  └─ sahel_app.dart               # MaterialApp.router
├─ core/
│  ├─ constants/api_endpoints.dart # كل مسارات الـ API
│  ├─ network/api_client.dart      # Dio + التوكن + الترويسات
│  ├─ providers.dart               # شجرة الـ DI (Riverpod)
│  └─ storage/                     # التخزين الآمن + SQLite
├─ data/
│  ├─ sources/remote_sources.dart  # استدعاءات الـ HTTP
│  └─ repositories/                # auth / catalog / customer / provider + parsers
├─ providers/                      # auth_provider + data_providers + settings_provider
├─ modules/
│  ├─ auth/screens/                # splash, login, register, otp, kyc
│  ├─ customer/screens/            # شاشات العميل (~25)
│  └─ provider/screens/            # شاشات مقدم الخدمة (~15)
└─ shared/widgets/                 # مكونات مشتركة
```

## 6. الـ API

- Base prefixes: `/api` (عام) · `/api/auth` · `/api/customer` · `/api/provider`
- غلاف الاستجابة: `{status, message, data}` — يُفك عبر `apiData()` في `parsers.dart`
- الترويسات المرسلة تلقائياً: `Authorization: Bearer`, `Accept-Language`,
  `X-Currency`, `X-Device-ID`, `X-App-Version`, `X-Client-Type`
- المرجع الكامل: `mobile-api-operations-spec.md`

---

## 7. استكشاف الأخطاء

| المشكلة | الحل |
|---|---|
| `pub get` يرفض الإصدار | ثبّت Flutter `>=3.47.4` — لا تستخدم نسخاً قديمة |
| "تعذر الاتصال بالخادم" على الجوال | نفّذ `adb reverse tcp:8000 tcp:8000` وتأكد أن الخادم يعمل على `0.0.0.0` |
| الخادم لا يستجيب عبر IP الشبكة | جدار Windows يحجب المنفذ — أضف القاعدة (قسم 4) أو استخدم `adb reverse` |
| المحاكي: "Not enough disk space" | حرّر مساحة على قرص `C:` أو انقل الـ AVD لقرص آخر وحدّث `ANDROID_AVD_HOME` |
| فشل Kotlin incremental عبر قرصين | مضبوط مسبقاً: `kotlin.incremental=false` في `gradle.properties` |
| بطء أول build | طبيعي — تنزيل NDK/CMake وترجمة كل الإضافات لأول مرة |

## 8. أوامر سريعة

```bash
flutter pub get        # تبعيات
flutter analyze        # تحليل ثابت
flutter test           # الاختبارات
flutter run            # تشغيل debug
flutter build apk --debug          # APK تجريبي
flutter build apk --release        # APK نهائي
```
