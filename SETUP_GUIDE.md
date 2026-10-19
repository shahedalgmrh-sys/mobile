# دليل تشغيل مشروع ساحل — خطوة بخطوة

> هذا الدليل لتشغيل المشروع كاملاً على جهازك أنت — كل شيء محلي، لا تحتاج أي اتصال بجهاز أحد.

---

## 🔧 ليش يظهر "تعذر الاتصال بالخادم"؟

التطبيق **واجهة فقط** — بدون خادم Laravel يشتغل على جهازك، ما فيه بيانات يعرضها.
الحل: تشغّل الباك-إند محلياً عندك.

---

## الخطوة 1 — ثبّت الأدوات (مرة واحدة)

| الأداة | التحميل |
|---|---|
| PHP 8.2+ | XAMPP أو Laragon |
| Composer | https://getcomposer.org |
| Flutter 3.47.5 | من صفحة **Releases** في الـ repo (ملف `flutter_windows_3.47.5-stable.zip`) أو https://docs.flutter.dev |
| Android Studio | للمحاكي + أدوات Android |
| Git | https://git-scm.com |

> Flutter يأتي معه Dart — لا تحتاج تثبيت Dart منفصلاً.

بعد تثبيت Flutter: فك الضغط في `C:\flutter-sdk\flutter` وأضف `C:\flutter-sdk\flutter\bin` إلى PATH، ثم افتح طرفية ج
flutter doctor --android-licenses
```

---

## الخطوة 2 — شغّل الخادم (Backend)

```bash
git clone https://github.com/shahedalgmrh-sys/saber.git
cd saber

composer install
cp .env.example .env
php artisan key:generate
type nul > database\database.sqlite
php artisan migrate --seed --force
php artisan serve --host=0.0.0.0 --port=8000
```

**اترك النافذة مفتوحة** — هذا هو الخادم.

تحقق أنه يعمل: افتح في المتصفح
```
http://127.0.0.1:8000/api/health
```
لازم يرجع: `{"status":"ok","service":"sahel-home-services",...}`

---

## الخطوة 3 — شغّل التطبيق (Mobile)

في طرفية **ثانية**:

```bash
git clone https://github.com/shahedalgmrh-sys/mobile.git
cd mobile
flutter pub get
```

### إذا تستخدم محاكي Android:

```bash
flutter run
```
العنوان الافتراضي `10.0.2.2:8000` يوصل لجهازك تلقائياً — ما تحتاج أي شيء إضافي.

### إذا تستخدم جوال حقيقي بكيبل USB:

```bash
adb reverse tcp:8000 tcp:8000
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

> `adb reverse` يوجّه منفذ الجوال للكمبيوتر عبر الكيبل — يعمل بدون WiFi وبدون جدار حماية.
> **إذا فصلت الكيبل أعد الأمر مرة ثانية.**

### إذا تستخدم جوال على نفس WiFi الكمبيوتر:

```bash
# اعرف IP جهازك: ipconfig → مثلاً 192.168.0.102
# افتح المنفذ في جدار الحماية (PowerShell كمسؤول):
netsh advfirewall firewall add rule name="Laravel API 8000" dir=in action=allow protocol=TCP localport=8000

# شغّل:
flutter run --dart-define=API_BASE_URL=http://192.168.0.102:8000/api
```

---

## الخطوة 4 — سجّل دخول

| الدور | البريد | كلمة المرور |
|---|---|---|
| عميل | `customer@sahel.com` | `Password123!` |
| مقدم خدمة | `provider@sahel.com` | `Password123!` |
| عملاء إضافيون | `customer1..10@sahel.com` | `Password123!` |
| مزودون إضافيون | `provider1..10@sahel.com` | `Password123!` |

---

## ⚠️ أخطاء متوقعة — عادية ولا تقلق

| الخطأ | الحقيقة |
|---|---|
| `LoadTestSeeder` يفشل في آخر الـ seed | طبيعي — يستخدم صيغة MySQL على SQLite. البيانات الأساسية زُرعت قبله |
| أول `flutter run` يأخذ 30+ دقيقة | طبيعي — ينزّل NDK ويبني الإضافات، المرة الجاية أسرع بكثير |
| `pub get` يرفض الإصدار | ثبّت Flutter `>=3.47.4` |
| رجع "تعذر الاتصال" بعد فصل الكيبل | أعد `adb reverse tcp:8000 tcp:8000` |
| الجوال "unauthorized" | اقبل رسالة "السماح بتصحيح USB" على الجوال |

---

## الخلاصة

```
جهازك ← تطبيق Flutter ← خادم Laravel محلي (SQLite)
كل واحد يشغّل كل شيء على جهازه — البيانات تجريبية محلية.
```

## روابط الـ repos

| المشروع | الرابط |
|---|---|
| الموبايل | https://github.com/shahedalgmrh-sys/mobile |
| الويب/الباك-إند | https://github.com/shahedalgmrh-sys/saber |

> إذا ما قدرت تسحب الـ repos لأنها خاصة — اطلب من صاحب المشروع يضيفك Collaborator
> من: Settings → Collaborators → Add people
