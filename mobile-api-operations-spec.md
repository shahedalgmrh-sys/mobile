# دليل عمليات العميل والمزود لتطبيقات الجوال (Customer & Provider Mobile Operations Spec)

هذا المستند مخصص لمطور تطبيقات الجوال (Flutter / React Native / Native) لتنفيذ كافة شاشات وعمليات التطبيق للعميل والمزود بدون واجهات الإدارة (Admin).

---

## 1. بيانات تسجيل الدخول التجريبية (Demo Accounts for Testing)

| الدور (Role) | البريد الإلكتروني (Email) | كلمة المرور (Password) | الوصف |
| :--- | :--- | :--- | :--- |
| **عميل (Customer)** | `customer@sahel.com` | `Password123!` | حساب عميل جاهز يحتوي على عناوين وحجوزات سابقة. |
| **مزود خدمة (Provider)** | `provider@sahel.com` | `Password123!` | حساب مزود معتمد وموثق لديه خدمات وطلبات واردة. |

---

## 2. الإعدادات العامة والتوثيق (Headers & Authorization)

* **Base URL:** `https://api.yourdomain.com/api` (أو رابط السيرفر المحلي)
* **Headers الإلزامية في كل الطلبات:**
  ```http
  Accept: application/json
  Content-Type: application/json
  ```
* **Headers في الطلبات المحمية (بعد تسجيل الدخول):**
  ```http
  Authorization: Bearer {TOKEN}
  ```

---

## 3. المصادقة والتحكم بالدور المزدوج (Authentication & Role Switching)

### 3.1 إنشاء حساب تفاعلي بحسب الدور (Dynamic Single-Page Role Registration)

في شاشة إنشاء الحساب بالتطبيق، يتم عرض بطاقتي اختيار الدور **(عميل / مزود خدمة)** في أعلى نفس الشاشة لتحديد واجهة الحقول والتوجيه:

#### آلية العمل في واجهة التطبيق (UI Logic):
* **عند اختيار "عميل (Customer)":**
  * تظهر الحقول الأساسية: (الاسم، الجوال، البريد، كلمة المرور).
  * بعد نجاح الإرسال يتم حفظ الـ `token` وتوجيه العميل مباشرة إلى: **الواجهة الرئيسية لتصفح وحجز الخدمات (`Customer Home`).**
* **عند اختيار "مزود خدمة (Provider)":**
  * تنبثق في نفس الصفحة الحقول الإضافية: (الاسم التجاري `business_name`، رقم الهوية أو السجل `national_id_or_cr`، ورفع وثائق الاعتماد `documents[]`).
  * بعد نجاح الإرسال يتم حفظ الـ `token` وتوجيه المزود مباشرة إلى: **واجهة متابعة حالة الاعتماد ولوحة تحكم المزود (`Provider Dashboard / Verification`).**

#### الطلب (Request):
* **المسار:** `POST /api/auth/register`
* **النوع:** Public (Multipart Form-Data)
* **المدخلات (Payload للعميل):**
  ```json
  {
    "name": "عبدالله الحربي",
    "phone": "+966500000001",
    "email": "customer@example.com",
    "password": "Password123!",
    "password_confirmation": "Password123!",
    "role": "customer",
    "device_name": "iPhone 15"
  }
  ```
* **المدخلات (Payload لمزود الخدمة):**
  ```json
  {
    "name": "فهد السبيعي",
    "phone": "+966550000002",
    "email": "provider@example.com",
    "password": "Password123!",
    "password_confirmation": "Password123!",
    "role": "provider",
    "business_name": "مؤسسة فهد للصيانة والتكييف",
    "national_id_or_cr": "1010998877",
    "documents": ["file1.pdf", "license.jpg"],
    "device_name": "Galaxy S24"
  }
  ```

#### الاستجابة (Response 201 Created):
```json
{
  "status": "success",
  "message": "Registration successful. A verification OTP has been sent.",
  "data": {
    "user": {
      "id": 20,
      "name": "عبدالله الحربي",
      "phone": "+966500000001",
      "email": "customer@example.com",
      "role": "customer", // يحدد التطبيق من خلال هذا الحقل وجهة التوجيه التالية
      "account_status": "active", // للمزود تكون "pending"
      "is_verified": false
    },
    "token": "1|abc123456...",
    "otp_sent": true
  }
}
```

#### التوجيه التلقائي البرمجي في التطبيق (Client-Side Navigation Rule):
```dart
if (response.data['user']['role'] == 'customer') {
  Navigator.pushReplacementNamed(context, '/customer-home');
} else {
  Navigator.pushReplacementNamed(context, '/provider-verification-status');
}
```

### 3.2 تسجيل الدخول (Login)
* **المسار:** `POST /api/auth/login`
* **المدخلات:**
  ```json
  {
    "login": "customer@sahel.com", // يقبل الهاتف أو البريد
    "password": "Password123!",
    "device_name": "Pixel 8"
  }
  ```
* **الاستجابة (200 OK):**
  ```json
  {
    "status": "success",
    "message": "Logged in successfully.",
    "data": {
      "user": {
        "id": 3,
        "name": "Customer User",
        "role": "customer",
        "is_verified": true
      },
      "token": "2|abc..."
    }
  }
  ```

### 3.3 التحقق من رمز الـ OTP (Verify OTP)
* **المسار:** `POST /api/auth/verify-otp` (Protected)
* **المدخلات:** `{"otp": "123456"}`

### 3.4 الملف الشخصي وتسجيل الخروج
* `GET /api/auth/user` (Protected) — جلب بيانات المستخدم المسجل حالياً وصلاحياته ومحفظته.
* `POST /api/auth/logout` (Protected) — تسجيل الخروج وإبطال التوكن.

---

## 4. عمليات العميل (Customer Operations)

كل طلبات هذا القسم مسبوقة بـ `/api/customer/` وتتطلب توكن العميل.

### 4.1 إدارة العناوين (Customer Addresses)
* **عرض العناوين:** `GET /api/customer/addresses`
* **إضافة عنوان:** `POST /api/customer/addresses`
  ```json
  {
    "label": "المنزل",
    "city_id": 1,
    "area_id": 2,
    "address_line_1": "شارع الملك فهد، مبنى 40",
    "building": "برج النخيل",
    "floor": "3",
    "apartment": "302",
    "latitude": 24.7136,
    "longitude": 46.6753,
    "phone": "+966500000001",
    "is_default": true
  }
  ```
* **تعديل عنوان:** `PUT /api/customer/addresses/{addressId}`
* **حذف عنوان:** `DELETE /api/customer/addresses/{addressId}`

### 4.2 الحجوزات والخدمات (Booking Flow)
* **استعراض حجوزاتي:** `GET /api/customer/bookings?status=pending` (يدعم الفلترة: `pending`, `accepted`, `in_progress`, `completed`, `cancelled`).
* **إنشاء حجز خدمة جديد:** `POST /api/customer/bookings`
  ```json
  {
    "service_id": 1,
    "customer_address_id": 1,
    "booking_date": "2026-10-25",
    "booking_time": "14:30",
    "coupon_code": "DISCOUNT10", // اختياري
    "notes": "يرجى الحضور في الموعد بالضبط"
  }
  ```
* **تفاصيل الحجز:** `GET /api/customer/bookings/{bookingId}`
* **التتبع المباشر للحجز (Live Tracking):** `GET /api/customer/bookings/{bookingId}/track`
  * يُرجع: الحالة الآنية، خط سير الحالات السابقة، موقع المزود الحالي على الخريطة وموقع العميل.
* **إعادة الجدولة:** `POST /api/customer/bookings/{bookingId}/reschedule`
  ```json
  {
    "booking_date": "2026-10-26",
    "booking_time": "16:00",
    "reason": "تغيير الموعد لظرف طارئ"
  }
  ```
* **إعادة الطلب السريع (Re-book):** `POST /api/customer/bookings/{bookingId}/rebook`
* **إلغاء الحجز:** `POST /api/customer/bookings/{bookingId}/cancel`
  ```json
  {
    "reason": "لم أعد بحاجة للخدمة"
  }
  ```

### 4.3 الدفع والفواتير (Payments & Invoices)
* **دفع وسداد الحجز:** `POST /api/customer/bookings/{bookingId}/pay`
  ```json
  {
    "payment_method": "apple_pay" // الخيارات: mada, apple_pay, stc_pay, card, wallet, cash
  }
  ```
* **قائمة المدفوعات:** `GET /api/customer/payments`
* **الفاتورة الضريبية الإلكترونية:** `GET /api/customer/payments/{paymentId}/invoice`

### 4.4 المحفظة والمفضلة (Wallet & Favorites)
* **عرض رصيد المحفظة:** `GET /api/customer/wallet`
* **سجل المعاملات والعمليات:** `GET /api/customer/wallet/transactions`
* **شحن رصيد المحفظة:** `POST /api/customer/wallet/add-funds`
  ```json
  {
    "amount": 250.00,
    "payment_method": "mada"
  }
  ```
* **المفضلة:**
  * `GET /api/customer/favorites` — عرض قائمة الخدمات والمزودين المفضلين.
  * `POST /api/customer/favorites/toggle` — إضافة/إزالة خدمة من المفضلة (`{"service_id": 1}`).
  * `POST /api/customer/favorites/providers/{providerId}/toggle` — تفضيل مزود خدمة.

### 4.5 التقييمات والشكاوى والمحادثات
* **تقييم المزود بعد انتهاء الحجز:** `POST /api/customer/reviews`
  ```json
  {
    "booking_id": 5,
    "rating": 5, // من 1 إلى 5
    "comment": "خدمة ممتازة وفني محترف جداً"
  }
  ```
* **رفع شكوى أو تذكرة دعم:** `POST /api/customer/complaints`
  ```json
  {
    "booking_id": 5,
    "subject": "تأخر في موعد الحضور",
    "description": "وصل الفني بعد الوقت المحدد بساعة كاملة",
    "priority": "medium"
  }
  ```
* **الدردشة المباشرة (Chat):**
  * `GET /api/customer/conversations` — قائمة المحادثات.
  * `GET /api/customer/conversations/{conversationId}` — استعراض رسائل المحادثة.
  * `POST /api/customer/conversations/{conversationId}/messages` — إرسال رسالة (`{"body": "أهلاً بك، متى ستصل؟"}`).

---

## 5. عمليات مزود الخدمة (Provider Operations)

كل طلبات هذا القسم مسبوقة بـ `/api/provider/` وتتطلب توكن مزود معتمد.

### 5.1 لوحة التحكم والإحصائيات (Provider Dashboard)
* **المسار:** `GET /api/provider/dashboard`
* **الاستجابة:**
  ```json
  {
    "status": "success",
    "data": {
      "metrics": {
        "today_bookings": 3,
        "pending_bookings": 2,
        "completed_bookings": 48,
        "total_earnings": 8450.00,
        "wallet_balance": 1200.00,
        "rating": 4.9,
        "total_reviews": 35
      },
      "recent_bookings": [ ... ],
      "recent_reviews": [ ... ]
    }
  }
  ```

### 5.2 إدارة دورة حياة حجوزات المزود (Orders Lifecycle)
* **قائمة الحجوزات الواردة:** `GET /api/provider/bookings?status=pending` (مع إمكانية تصفية بالتاريخ `?date=2026-10-25`).
* **تفاصيل الحجز وموقع العميل:** `GET /api/provider/bookings/{id}`
* **قبول الحجز:** `POST /api/provider/bookings/{id}/accept`
* **رفض الحجز:** `POST /api/provider/bookings/{id}/reject`
  ```json
  {
    "reason": "الموعد يتعارض مع جدول الصيانة المجدول"
  }
  ```
* **بدء تنفيذ الخدمة (Start Service):** `POST /api/provider/bookings/{id}/start`
* **إنهاء واكتمال الخدمة (Complete):** `POST /api/provider/bookings/{id}/complete`
* **طلب إعادة الجدولة للمزود:** `POST /api/provider/bookings/{id}/reschedule`
  ```json
  {
    "scheduled_date": "2026-10-26",
    "scheduled_time": "15:00",
    "reason": "ازدحام مروري وتأخر في الموقع السابق"
  }
  ```

### 5.3 إدارة خدمات المزود (My Services)
* **استعراض خدماتي:** `GET /api/provider/services`
* **إضافة خدمة جديدة:** `POST /api/provider/services`
  ```json
  {
    "category_id": 1,
    "title": "صيانة مكيفات سبليت شامل التنظيف",
    "description": "فحص غاز الفريون وتنظيف الفلاتر بالكامل",
    "price": 180.00,
    "duration_minutes": 60,
    "is_available": true
  }
  ```
* **تعديل خدمة:** `PUT /api/provider/services/{id}`
* **حذف خدمة:** `DELETE /api/provider/services/{id}`
* **تفعيل/تعطيل استقبال الطلبات على خدمة:** `POST /api/provider/services/{id}/toggle-active`
* **تكرار ونسخ خدمة:** `POST /api/provider/services/{id}/duplicate`

### 5.4 مواعيد العمل ومناطق التغطية (Availability & Coverage)
* **استعراض الجدول والمناطق:** `GET /api/provider/availability`
* **تحديد ساعات العمل لكل يوم:** `POST /api/provider/availability/working-hours`
  ```json
  {
    "day_of_week": 1, // 0 = الأحد, 1 = الإثنين ... 6 = السبت
    "start_time": "08:00",
    "end_time": "18:00"
  }
  ```
* **حذف وقت عمل:** `DELETE /api/provider/availability/working-hours/{id}`
* **إضافة منطقة أو حي للتغطية:** `POST /api/provider/availability/areas`
  ```json
  {
    "city_id": 1,
    "area_id": 3 // اختياري
  }
  ```
* **حذف منطقة تغطية:** `DELETE /api/provider/availability/areas/{id}`

### 5.5 المحفظة وسحب الأرباح البنكية (Earnings & Withdrawals)
* **رصيد الأرباح:** `GET /api/provider/wallet`
* **قائمة طلبات السحب:** `GET /api/provider/withdrawals`
* **طلب تحويل أرباح لحساب بنكي:** `POST /api/provider/withdrawals`
  ```json
  {
    "amount": 1000.00,
    "bank_name": "مصرف الراجحي",
    "account_number": "123456789012345",
    "account_holder_name": "مؤسسة الرواد للخدمات",
    "iban": "SA0380000000123456789012",
    "notes": "سحب أرباح أسبوعي"
  }
  ```
* **إلغاء طلب سحب معلق:** `POST /api/provider/withdrawals/{id}/cancel`

### 5.6 معرض الأعمال (Portfolio)
* **عرض معرض الأعمال:** `GET /api/provider/portfolio`
* **إضافة عمل للملف المهني:** `POST /api/provider/portfolio` (Form-Data: `title`, `description`, `image`, `category`, `budget`, `client_name`).
* **حذف عمل:** `DELETE /api/provider/portfolio/{id}`

### 5.7 طلبات B2B بين المزودين ("طلباتي")
*إذا احتاج المزود للاستعانة بمزود آخر أو تلقي طلب دعم من مزود:*
* **عرض الطلبات:** `GET /api/provider/requests?type=incoming` (أو `type=outgoing`)
* **إرسال طلب لمزود آخر:** `POST /api/provider/requests`
  ```json
  {
    "target_provider_id": 2,
    "service_id": 4,
    "city_id": 1,
    "address_line": "حي العليا، شارع التحلية",
    "scheduled_date": "2026-10-27",
    "scheduled_time": "10:00",
    "description": "طلب دعم فني في تركيب وحدات خارجية"
  }
  ```
* **قبول / رفض الطلب:** `POST /api/provider/requests/{id}/accept` و `POST /api/provider/requests/{id}/reject`.

---

## 6. المحتوى العام والاستكشاف (Public Feed - شاشات البداية)

* **خلاصة الصفحة الرئيسية:** `GET /api/home` (يرجع التصنيفات، الخدمات الشائعة، العروض، وأفضل المزودين).
* **قائمة الأقسام:** `GET /api/categories`
* **دليل الخدمات مع البحث:** `GET /api/services?q=تنظيف&category_id=1&sort=rating`
* **دليل المزودين:** `GET /api/providers?city_id=1`
* **صفحة المزود العامة:** `GET /api/providers/{id}` (معرض الأعمال، التقييمات، والخدمات المتاحة).
* **قائمة المدن والأحياء:** `GET /api/cities` و `GET /api/cities/{cityId}/areas`
* **العروض والخصومات:** `GET /api/offers`
