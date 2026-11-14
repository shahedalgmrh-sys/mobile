# خريطة ربط وظائف تقرير REST API بشاشات Flutter

**النطاق:** `E:\saber\mobile` فقط — بدون أي تعديل على Laravel أو `routes/api.php` أو قاعدة البيانات أو الموقع.

**المرجع الوظيفي:** `E:\saber\mobile\mobile-api-operations-spec.md` (69 عملية).

**منهجية التحقق (قراءة فقط):**
1. مطابقة كل وظيفة في التقرير مع تعريف المسار الفعلي في `SaberWeb-main/routes/api.php`.
2. قراءة الـ Controller والـ Resource للتأكد من حقول الطلب والاستجابة الفعلية.
3. قراءة كود Flutter (الشاشة ← Repository ← RemoteSource ← `ApiEndpoints`) للتأكد من الربط الحالي.
4. لم تُجرَ أي تعديلات على الباك إند، ولم تُستخدم بيانات وهمية.

## رموز الحالة

| الرمز | المعنى |
| :--- | :--- |
| ✅ | API موجود ويعمل والواجهة مربوط به فعلياً |
| 🟡 | API موجود والواجهة تعمل جزئياً أو تعرض حقولاً أقل من المتاح |
| 🔴 | API موجود لكن الواجهة ناقصة — **قابل للتنفيذ داخل Flutter فقط** |
| ⛔ | `BLOCKED_BY_API` — الوظيفة غير قابلة للتنفيذ بسبب نقص/تعارض في الـ API |
| ⚠️ | اختلاف بين عقد التقرير والعقد الفعلي، تمت المواءمة في Flutter |

---

## 1) المصادقة (Authentication)

| # | وظيفة التقرير | المسار الفعلي (متحقق) | شاشة/ملف Flutter | الحالة | الفجوة / الملاحظة |
| :-- | :--- | :--- | :--- | :--- | :--- |
| A1 | تسجيل حساب عميل | `POST /api/auth/register` | `modules/auth/screens/register_screen.dart` | ✅ | الحقول الأساسية مدعومة، والتوجيه حسب `role` يعمل. |
| A2 | تسجيل حساب مزود مع حقول النشاط | `POST /api/auth/register` | نفس الشاشة + `auth_repository.dart` | ✅ | **نُفّذ في المرحلة 1:** اختيار متعدد للوثائق ورفعها كـ `documents[]` (PDF/JPG/PNG، حد 10MB) بمعالجة تحميل وفشل وإعادة محاولة. حقلا `business_name` و`national_id_or_cr` لا يُرسلان. |
| A3 | إرسال `business_name` و`national_id_or_cr` عند التسجيل | — | — | ⛔ | الباك إند لا يتحقق من الحقلين ولا يخزنهما؛ يُنشئ `business_name` من `name`. أي واجهة لهما ستوهم المستخدم. |
| A4 | تسجيل الدخول | `POST /api/auth/login` | `modules/auth/screens/login_screen.dart` | ✅ | يقبل بريداً أو هاتفاً، ويوجّه حسب الدور. |
| A5 | التحقق من OTP | `POST /api/auth/verify-otp` | `modules/auth/screens/otp_screen.dart` | ✅ | التوجيه يتم عبر `app_router.dart`. |
| A6 | إعادة إرسال OTP | `POST /api/auth/resend-otp` | شاشة OTP | ✅ | موجود في التطبيق وإن لم يذكره التقرير. |
| A7 | جلب المستخدم الحالي | `GET /api/auth/user` | `auth_repository.me()` | ✅ | — |
| A8 | تسجيل الخروج | `POST /api/auth/logout` | `auth_provider.dart` | ✅ | — |
| A9 | توجيه المزود بعد التسجيل إلى حالة الاعتماد | — | `modules/provider/screens/kyc_status_screen.dart` | ✅ | **نُفّذ في المرحلة 1:** التوجيه يقرأ `provider_profile.is_verified` من استجابة API ويذهب إلى `/p/kyc` عند عدم الاعتماد، أو `/p/dashboard` عند الاعتماد. |

---

## 2) عمليات العميل

### 2.1 العناوين

| # | وظيفة التقرير | المسار الفعلي | شاشة Flutter | الحالة | الملاحظة |
| :-- | :--- | :--- | :--- | :--- | :--- |
| C1 | عرض العناوين | `GET /api/customer/addresses` | `address_book_screen.dart` | ✅ | — |
| C2 | إضافة عنوان (مع `is_default`) | `POST /api/customer/addresses` | `address_book_screen.dart` | ✅ | يرسل `city_id`, `area_id`, `is_default`. |
| C3 | تعديل عنوان | `PUT /api/customer/addresses/{id}` | نفس الشاشة | ✅ | — |
| C4 | حذف عنوان | `DELETE /api/customer/addresses/{id}` | نفس الشاشة | ✅ | — |

### 2.2 الحجوزات

| # | وظيفة التقرير | المسار الفعلي | شاشة Flutter | الحالة | الملاحظة |
| :-- | :--- | :--- | :--- | :--- | :--- |
| C5 | قائمة الحجوزات مع فلترة الحالة | `GET /api/customer/bookings?status=&page=` | `bookings/bookings_list_screen.dart` | ✅ | **نُفّذ في المرحلة 4:** 15 حجزاً لكل صفحة مع `meta` و«تحميل المزيد». التبويبات ترسل حالات API الفعلية فقط (`pending/accepted/in_progress/completed/cancelled`)؛ أُزيل تبويب «القادمة» لأنه كان يرسل `status=upcoming` غير المخزّن في الباك إند فمعه دائماً فارغاً. |
| C6 | إنشاء حجز | `POST /api/customer/bookings` | `bookings/booking_wizard_screen.dart` | ⚠️✅ | التقرير يذكر `service_id`، والعقد الفعلي يستخدم `service_pricing_id` (اختياري) + `payment_method` + `idempotency`. Flutter متوافق مع العقد الفعلي. |
| C7 | تفاصيل الحجز | `GET /api/customer/bookings/{id}` | `bookings/booking_details_screen.dart` | ✅ | — |
| C8 | التتبع المباشر | `GET /api/customer/bookings/{id}/track` | `bookings/live_tracking_screen.dart` | ✅ | — |
| C9 | إعادة الجدولة | `POST /api/customer/bookings/{id}/reschedule` | `booking_details_screen.dart` | ✅ | — |
| C10 | إعادة الطلب السريع | `POST /api/customer/bookings/{id}/rebook` | `booking_details_screen.dart` | ✅ | — |
| C11 | إلغاء الحجز | `POST /api/customer/bookings/{id}/cancel` | `booking_details_screen.dart` | ✅ | — |

### 2.3 الدفع والفواتير

| # | وظيفة التقرير | المسار الفعلي | شاشة Flutter | الحالة | الملاحظة |
| :-- | :--- | :--- | :--- | :--- | :--- |
| C12 | دفع الحجز | `POST /api/customer/bookings/{id}/pay` | `booking_details_screen.dart` | ✅ | طرق الدفع موحّدة في `core/constants/payment_methods.dart`. |
| C13 | قائمة المدفوعات | `GET /api/customer/payments` | `payments_screen.dart` | ✅ | — |
| C14 | الفاتورة الضريبية | `GET /api/customer/payments/{id}/invoice` | `payment_invoice_screen.dart` | ✅ | — |

### 2.4 المحفظة والمفضلة

| # | وظيفة التقرير | المسار الفعلي | شاشة Flutter | الحالة | الملاحظة |
| :-- | :--- | :--- | :--- | :--- | :--- |
| C15 | رصيد المحفظة | `GET /api/customer/wallet` | `wallet/wallet_screen.dart` | ✅ | — |
| C16 | سجل المعاملات داخل شاشة المحفظة | `GET /api/customer/wallet/transactions` | `wallet/wallet_screen.dart` | ⚠️✅ | **نُفّذ في المرحلة 4:** يعيد الباك إند آخر 20 عملية ثابتة (`transactions($id, 20)`) بلا ترقيم، والواجهة تذكر ذلك صراحةً بدل الإيحاء بعرض كامل. |
| C16b | كشف الحساب مع الترقيم | `GET /api/customer/reports/wallet?page=` | `wallet/wallet_statement_screen.dart` | ✅ | **نُفّذ في المرحلة 4:** الباك إند يعيد paginator كاملاً (20/صفحة + `current_page/last_page/total`)، والشاشة تعرض الملخص و«عرض X من Y» وتحمّل الصفحات التالية عند الوصول للنهاية مع إعادة محاولة عند الفشل. |
| C17 | شحن الرصيد | `POST /api/customer/wallet/add-funds` | `wallet_screen.dart` | ⚠️✅ | **نُفّذ في المرحلة 4:** الاستجابة تعيد `checkout_url` لصفحة ويب تتطلب جلسة الموقع؛ التطبيق يوضح ذلك ويفتحها خارجياً، ثم يؤكد عبر `confirm` بعد إتمام الدفع. لا تُنشأ أرصدة محلية ولا تُفترض قيم من الاستجابة. |
| C18 | قائمة المفضلة | `GET /api/customer/favorites` | `favorites_screen.dart` | ✅ | — |
| C19 | تفضيل/إزالة خدمة | `POST /api/customer/favorites/toggle` | زر المفضلة في تفاصيل الخدمة | ✅ | — |
| C20 | تفضيل/إزالة مزود | `POST /api/customer/favorites/providers/{id}/toggle` | `provider_profile_screen.dart` | ✅ | `FavoriteToggleButton(isProvider: true)`. |

### 2.5 التقييمات والشكاوى والمحادثات

| # | وظيفة التقرير | المسار الفعلي | شاشة Flutter | الحالة | الملاحظة |
| :-- | :--- | :--- | :--- | :--- | :--- |
| C21 | إضافة تقييم بعد الحجز | `POST /api/customer/reviews` | `write_review_screen.dart` | ✅ | — |
| C22 | رفع شكوى | `POST /api/customer/complaints` | `submit_complaint_screen.dart` | ✅ | **نُفّذ في المرحلة 4:** متاح من `/complaints/new` ومن تفاصيل الحجز عبر `/bookings/{id}/complaint` (يُرسل `booking_id` الحقيقي)، وبعد النجاح ينتقل إلى `/complaints/{newId}`. الأولوية المختارة تُرسل كما هي. |
| C23 | قائمة الشكاوى | `GET /api/customer/complaints` | `complaints_screen.dart` | 🟡 | يعرض الحالة/الأولوية/آخر رد. القيد: الباك إند يعيد آخر 15 شكوى فقط بلا ترقيم، والواجهة تذكر ذلك بوضوح. |
| C24 | قائمة المحادثات | `GET /api/customer/conversations` | `messages_list_screen.dart` | ✅ | — |
| C25 | رسائل محادثة | `GET /api/customer/conversations/{id}` | `chat_screen.dart` | ✅ | — |
| C26 | إرسال رسالة (العميل) | `POST /api/customer/conversations/{id}/messages` | `chat_screen.dart` | ✅ | يرسل `body` كما في العقد. |
| C27 | صفحة شكوى جديدة من شريط الشكاوى | — | `complaints_screen.dart` | ✅ | **نُفّذ في المرحلة 4:** زر AppBar يفتح `/complaints/new` المعرّف بدل `/complaint`. |
| C28 | تفاصيل الشكوى وردود الدعم | `GET /api/customer/complaints` (نفس القائمة) | `complaints/complaint_details_screen.dart` | ✅ | **نُفّذ في المرحلة 4:** تعرض `booking.service` و`against.name` والوصف والرسائل من الأقدم للأحدث. لا يوجد مسار show منفصل؛ التفاصيل تُبنى من القائمة. |

---

## 3) عمليات المزود

### 3.1 اللوحة والحجوزات

| # | وظيفة التقرير | المسار الفعلي | شاشة Flutter | الحالة | الملاحظة |
| :-- | :--- | :--- | :--- | :--- | :--- |
| P1 | لوحة التحكم والإحصائيات | `GET /api/provider/dashboard` | `provider_dashboard_screen.dart` | ✅ | يعرض `metrics` و`recent_*`. |
| P2 | قائمة الحجوزات + فلترة الحالة/التاريخ | `GET /api/provider/bookings` | `provider_bookings_screen.dart` | ✅ | — |
| P3 | تفاصيل الحجز | `GET /api/provider/bookings/{id}` | `provider_booking_details_screen.dart` | ✅ | — |
| P4 | قبول الحجز | `POST /api/provider/bookings/{id}/accept` | نفس الشاشة | ✅ | — |
| P5 | رفض الحجز بسبب | `POST /api/provider/bookings/{id}/reject` | نفس الشاشة | ✅ | — |
| P6 | بدء التنفيذ | `POST /api/provider/bookings/{id}/start` | نفس الشاشة | ✅ | الباك إند يفرض انتقالات صحيحة (422 عند التجاوز). |
| P7 | إنهاء الخدمة | `POST /api/provider/bookings/{id}/complete` | نفس الشاشة | ✅ | — |
| P8 | طلب إعادة جدولة من المزود | `POST /api/provider/bookings/{id}/reschedule` | — | ⛔ | المسار موجود لكنه يعيد **403 دائماً** بحسب تصميم الباك إند الحالي؛ لا واجهة. |
| P9 | إلغاء حجز من المزود (إضافي) | `POST /api/provider/bookings/{id}/cancel` | `provider_booking_details_screen.dart` | ✅ | غير مذكور في التقرير ولكنه يعمل. |

### 3.2 الخدمات

| # | وظيفة التقرير | المسار الفعلي | شاشة Flutter | الحالة | الملاحظة |
| :-- | :--- | :--- | :--- | :--- | :--- |
| P10 | عرض الخدمات | `GET /api/provider/services` | `service_catalog_screen.dart` | ✅ | — |
| P11 | إضافة خدمة | `POST /api/provider/services` | `provider_service_form_screen.dart` | ✅ | يدعم `category_id/title/description/price/duration_minutes/is_available` + صور عند الإنشاء. |
| P12 | تعديل خدمة | `PUT /api/provider/services/{id}` | نفس الشاشة | 🟡 | التعديل لا يدعم الصور ولا `pricing/faqs/requirements` (غير مدعومة في الباك إند وغير مطلوبة في التقرير). |
| P13 | حذف خدمة | `DELETE /api/provider/services/{id}` | `service_catalog_screen.dart` | ✅ | — |
| P14 | تفعيل/تعطيل استقبال الطلبات | `POST /api/provider/services/{id}/toggle-active` | `service_catalog_screen.dart` | ✅ | **نُفّذ في المرحلة 3:** مفتاح مستقل «مفعّلة/ظهور في الكتالوج» لا يستدعي `toggle-available`، ويعرض بانر تعليق إداري عند `is_administratively_suspended`. مؤكد من الـ Controller: يغيّر `is_active` و`deactivated_by` فقط، ويرفض 403 عند التعليق الإداري. |
| P15 | تكرار خدمة | `POST /api/provider/services/{id}/duplicate` | `service_catalog_screen.dart` | ✅ | — |
| P16 | تبديل توفر الخدمة (متاح/غير متاح) | `POST /api/provider/services/{id}/toggle-available` | `service_catalog_screen.dart` | ✅ | **نُفّذ في المرحلة 3:** ثابت `serviceToggleAvailable` + مفتاح مستقل «متاحة للحجز» منفصل تماماً عن التفعيل. مؤكد من الـ Controller: يغيّر `is_available` فقط دون أي تعديل على `is_active`. |

### 3.3 أوقات العمل ومناطق التغطية

| # | وظيفة التقرير | المسار الفعلي | شاشة Flutter | الحالة | الملاحظة |
| :-- | :--- | :--- | :--- | :--- | :--- |
| P17 | عرض الجدول والمناطق | `GET /api/provider/availability` | `working_hours_screen.dart` + إعدادات المناطق | ✅ | **نُفّذ في المرحلة 3:** شاشة `/p/working-hours` تعرض الأيام السبعة من `working_hours` مع ملاحظة صريحة بعدم دعم الإجازات. |
| P18 | إضافة ساعات عمل ليوم | `POST /api/provider/availability/working-hours` | `working_hours_screen.dart` | ✅ | **نُفّذ في المرحلة 3:** نافذة إضافة/تعديل بمنتقيات 24 ساعة، وتحقق `end > start`. مؤكد من الـ Controller والمهاجرة: القيد `unique(provider_id, day_of_week)` + `updateOrCreate`، فإعادة POST لنفس اليوم تعدّل السجل نفسه ولا تنشئ تكراراً. لا يوجد PUT منفصل. |
| P19 | حذف وقت عمل | `DELETE /api/provider/availability/working-hours/{id}` | `working_hours_screen.dart` | ✅ | **نُفّذ في المرحلة 3:** حذف بتأكيد مع حالات تحميل/خطأ. |
| P20 | إضافة منطقة تغطية | `POST /api/provider/availability/areas` | `provider_settings_screen.dart` | ✅ | **نُفّذ في المرحلة 3:** حقل `service_fee` اختياري يُرسل عند إدخاله، ويُعرض ضمن اسم المنطقة. تغيير رسوم منطقة قائمة يتطلب حذفاً وإعادة إضافة (لا يوجد PUT). |
| P21 | حذف منطقة تغطية | `DELETE /api/provider/availability/areas/{id}` | نفس الشاشة | ✅ | مؤكد: الحذف يمس صف `provider_areas` الخاص بالمزود فقط؛ لا يوجد أي جدول آخر يشير إلى `provider_areas.id` (لا `provider_area_id` في المهاجرات). إعادة الإضافة تنشئ صفاً بمعرّف جديد. أثر جانبي عرضي فقط: إن لم يكن لدى المزود إحداثيات مخزّنة، تُشتق `latitude/longitude/city` في `ProviderResource` من آخر منطقة نشطة، فقد تصبح `null` بعد حذف آخر منطقة — دون تغيير أي بيانات مخزنة. |
| P22 | «الإجازات» / استثناءات التوفر | — | — | ⛔ | لا يوجد أي مسار في الباك إند لاستثناءات أو إجازات (المتاح ساعات أسبوعية فقط). لا واجهة ولا بيانات بديلة. |

### 3.4 المحفظة والسحب

| # | وظيفة التقرير | المسار الفعلي | شاشة Flutter | الحالة | الملاحظة |
| :-- | :--- | :--- | :--- | :--- | :--- |
| P23 | رصيد الأرباح | `GET /api/provider/wallet` + `GET /api/provider/dashboard` | `earnings_screen.dart` و`provider_dashboard_screen.dart` | ⚠️✅ | **نُفّذ في المرحلة 3:** المحفظة لا تعيد إجمالي أرباح. مؤكد من `ProviderApiController::dashboard`: `total_earnings = SUM(net_amount)` لسجلات `provider_earnings` ذات `status = paid` فقط، أي **صافي مدفوع بعد العمولة وليس كل الأرباح**. التسمية في التطبيق: «إجمالي الأرباح المدفوعة» مع شرح «صافي أرباح الحجوزات المدفوعة بعد عمولة المنصة — كل الفترات»، و«غير متاح» عند غياب الحقل. |
| P24 | قائمة طلبات السحب | `GET /api/provider/withdrawals` | `earnings_screen.dart` | ✅ | — |
| P25 | طلب سحب | `POST /api/provider/withdrawals` | `withdraw_request_screen.dart` | ⚠️✅ | العقد الفعلي يطلب `transfer_method` (`bank/wallet/stc_pay`)؛ الشاشة ترسل `iban` و`bank_account_number` و`bank_name` مع المبلغ. متوافق. |
| P26 | إلغاء طلب سحب معلق | `POST /api/provider/withdrawals/{id}/cancel` | `earnings_screen.dart` | ✅ | — |

### 3.5 معرض الأعمال

| # | وظيفة التقرير | المسار الفعلي | شاشة Flutter | الحالة | الملاحظة |
| :-- | :--- | :--- | :--- | :--- | :--- |
| P27 | عرض المعرض | `GET /api/provider/portfolio` | `provider_settings_screen.dart` | ✅ | — |
| P28 | إضافة عمل | `POST /api/provider/portfolio` | نفس الشاشة | ✅ | **نُفّذ في المرحلة 3:** يرسل `image,title,description,category,completion_date,client_name,location,budget,is_featured`، ويعرض الشرائح في القائمة. حقلا `video/gallery` للقراءة فقط في الـ API ولا يُرسلان. |
| P29 | حذف عمل | `DELETE /api/provider/portfolio/{id}` | نفس الشاشة | ✅ | — |

### 3.6 طلبات B2B

| # | وظيفة التقرير | المسار الفعلي | شاشة Flutter | الحالة | الملاحظة |
| :-- | :--- | :--- | :--- | :--- | :--- |
| P30 | عرض الطلبات الواردة/الصادرة | `GET /api/provider/requests?type=` | `provider_service_requests_screen.dart` | ✅ | — |
| P31 | إنشاء طلب لمزود آخر | `POST /api/provider/requests` | `b2b_request_form_screen.dart` | ✅ | **نُفّذ في المرحلة 3:** نموذج من خطوتين (`/p/service-requests/new`): اختيار مزود آخر (بحث + ترقيم، باستثناء المزود نفسه) ثم الخدمة/المدينة/المنطقة/العنوان/التاريخ/الوقت/الوصف. يعرض فقط خدمات المزود `is_active && is_available`. |
| P32 | قبول الطلب | `POST /api/provider/requests/{id}/accept` | نفس الشاشة | ✅ | — |
| P33 | رفض الطلب | `POST /api/provider/requests/{id}/reject` | نفس الشاشة | ✅ | **نُفّذ في المرحلة 3:** الرفض بتأكيد بسيط فقط؛ الباك إند لا يخزّن سبب رفض لطلبات B2B، فأُزيل حقل السبب بدل إيهام المستخدم بحفظه. |
| P34 | إكمال الطلب (إضافي) | `POST /api/provider/requests/{id}/complete` | نفس الشاشة | ✅ | غير مذكور في التقرير. |

---

## 4) المحتوى العام والاستكشاف

| # | وظيفة التقرير | المسار الفعلي | شاشة Flutter | الحالة | الملاحظة |
| :-- | :--- | :--- | :--- | :--- | :--- |
| G1 | خلاصة الرئيسية | `GET /api/home` | `home/home_screen.dart` | ✅ | يعرض التصنيفات والخدمات المميزة/الشائعة ومزودين وعرضاً واحداً فقط. |
| G2 | قائمة الأقسام | `GET /api/categories` | الرئيسية / البحث | ✅ | الباك إند يعيد `id,name,slug` فقط (لا أقسام فرعية). |
| G3 | دليل الخدمات مع البحث والفلترة | `GET /api/services?q&category_id&sort` | `home/search_screen.dart` | ⚠️✅ | المسار العام يتجاهل الفلاتر فعلياً، لذلك Flutter يستخدم `/api/customer/search` المدعوم كاملاً (`q,type,category_id,city_id,min_price,max_price,min_rating,sort,latitude,longitude,radius_km`). **نُفّذ في المرحلة 4:** حدود شريط السعر الافتراضية لا تُرسل، ولا تُرسل إحداثيات دون تفعيل «بالقرب مني»، مع حالة «لا توجد نتائج» وإعادة ضبط الفلاتر. يعمل للعميل المسجّل. |
| G4 | دليل المزودين مع فلترة المدينة | `GET /api/providers?city_id=&q=&sort=&page=` | `home/providers_directory_screen.dart` | ✅ | **نُفّذ في المرحلة 2:** بحث بالاسم/الوصف، شرائح مدن من `/api/cities`، ترقيم عبر `meta`، حالات تحميل/خطأ/فراغ. |
| G5 | صفحة المزود العامة | `GET /api/providers/{id}` | `provider_profile_screen.dart` | ✅ | **نُفّذ في المرحلة 2:** `portfolios` تُعرض كمعرض أفقي مع نافذة تفاصيل (صورة/وصف/تصنيف/موقع/تاريخ/ميزانية) وتُخفى عند الفراغ. |
| G6 | قائمة المدن | `GET /api/cities` | البحث / العناوين / دليل المزودين | ✅ | — |
| G7 | أحياء المدينة | `GET /api/cities/{id}/areas` | البحث / العناوين | ✅ | — |
| G8 | العروض والخصومات | `GET /api/offers?page=&per_page=` | `home/offers_screen.dart` | ✅ | **نُفّذ في المرحلة 2:** شاشة كل العروض بحقول API الحقيقية (`discount_type/value`, `min_purchase`, تواريخ الصلاحية)، ترقيم احتياطي لأن `/offers` لا يعيد `meta`، وحالة فراغ حقيقية (قاعدة البيانات حالياً بلا عروض). |
| G9 | الإشعارات (وردت في طلبك) | `GET /api/customer/notifications` + `POST .../{id}/read` | `notifications/` | ✅ | لا يوجد مسار «تعليم الكل كمقروء» للعميل؛ التطبيق يعلّم فردياً. |

---

## 5) الوظائف المحجوبة نهائياً (`BLOCKED_BY_API`)

| الوظيفة | السبب الفعلي |
| :--- | :--- |
| `business_name` و`national_id_or_cr` عند التسجيل | `AuthApiController::register` لا يتحقق منهما ولا يخزنهما. |
| إعادة جدولة الحجز من المزود | المسار يعيد 403 دائماً. |
| الإجازات / استثناءات التوفر للمزود | لا يوجد مسار في `routes/api.php`؛ المتاح ساعات أسبوعية ثابتة فقط (نافذة واحدة لكل يوم). |
| تعديل ساعات عمل قائمة عبر `PUT` | لا يوجد مسار تحديث؛ `storeWorkingHour` يستخدم `updateOrCreate` بمفتاح `provider+day_of_week`، فالتعديل إعادة POST لنفس اليوم. |
| تعديل/تبديل منطقة تغطية | لا يوجد مسار update/toggle؛ المتاح إضافة وحذف فقط. تغيير `service_fee` يتطلب حذف المنطقة وإعادة إضافتها. |
| تعديل الصور/التسعير/الأسئلة للخدمة | غير مدعوم في `updateService` وغير مطلوب في التقرير. |
| `video` و`gallery` لمعرض الأعمال | يعيدهما `PortfolioResource` للقراءة فقط؛ `storePortfolio` يقبل الصورة وبيانات العمل فقط. |
| سبب رفض طلب B2B | `ProviderServiceRequestController` لا يخزّن سبباً ولا يعيده في `ServiceRequestResource`. |
| إجمالي الأرباح من المحفظة | `GET /provider/wallet` يعيد الرصيد والحركات فقط؛ الإجمالي الموثوق من `dashboard.metrics.total_earnings` (كل الفترات، صافي المدفوع). |
| تقرير الإيرادات بفلترة الحالة | مسار تقرير الإيرادات لا يدعم فلترة «مدفوع»، لذلك لا يُستخدم لاشتقاق الإجمالي. |
| محادثة شكوى (رد/إغلاق) | المسارات إدارية فقط (`/admin/complaints/*`) أو ويب بجلسة الموقع؛ العميل يملك list + create فقط. التفاصيل والردود تُقرأ من نفس استجابة القائمة. |
| ترقيم قائمة الشكاوى | `CustomerApiController::complaints` يمرر `complaintsByUser($userId, 15)` بلا paginator أو `page`؛ لا يمكن الوصول لشكوى أقدم من آخر 15 من التطبيق. |
| ترقيم `/customer/wallet/transactions` | الباك إند يستدعي `transactions($id, 20)` ويعيد قائمة ثابتة بلا `meta`؛ الترقيم متاح فقط عبر `/customer/reports/wallet`. |
| إتمام شحن المحفظة داخل التطبيق | `add-funds` يعيد `checkout_url` لصفحة ويب بمصادقة الجلسة، لا نية دفع داخلية؛ الإكمال ممكن في المتصفح ثم التأكيد عبر `confirm`. |
| تفاصيل خدمة مستقلة `GET /services/{slug}` | غير موجود؛ تفاصيل الخدمة تُستنتج من قوائم الخدمات. |
| تعليم كل إشعارات العميل كمقروءة | لا يوجد `read-all` للعميل. |
| فلاتر `/services` العامة (`q`, `category_id`, `sort`, `page`) | `ServiceController@index` يتجاهلها كلها ويكتفي بـ `limit` (افتراضي 12). البحث الفعلي يستخدم `/customer/search`؛ قوائم الخدمات العامة تطلب `limit=50` كحد أقصى. |
| هوية العميل في حجز المزود (الاسم) | `BookingResource` لا يحمّل `customer`؛ المتاح `address` (وقد يحمل هاتفاً) دون اسم. |
| مرفقات/مستندات الحجز | لا حقول مرفقات ولا مسارات رفع في `BookingResource` أو مسارات الحجز. |
| سجل رسائل المحادثة للمزود | `ProviderApiController::showConversation` يحمّل `messages.sender` لكن `ConversationResource` لا يعرض `messages`؛ الواجهة تعرض تنبيهاً صريحاً وتسمح بالإرسال فقط. |
| رد المزود على التقييم واسم صاحبه | `ReviewResource` لا يعرض `provider_reply` ولا `customer`؛ المتاح `review`, `rating`, `service`, `booking` المختصر. |
| ترقيم قوائم المزود | `services/bookings/withdrawals/reviews` تُرجع `paginate(15)` مع `meta`، لكن شاشات المزود الحالية تحمّل الصفحة الأولى فقط. الشاشات تعرض أول 15 عنصراً ولا توجد أزرار «المزيد». |
| إيداع/دفع مباشر في محفظة المزود | لا مسار إيداع للمزود؛ المتاح عرض الرصيد والسحب فقط. |

---

## 6) خطة التنفيذ المقترحة (داخل Flutter فقط)

| المرحلة | النطاق | المخرجات |
| :--- | :--- | :--- |
| **1. المصادقة** | رفع وثائق المزود `documents[]` عبر Multipart، إظهار الحقول الديناميكية مع تعطيل حقلي `business_name`/`national_id_or_cr` وشرح سبب التعطيل، وتوجيه المزود بعد OTP إلى `/p/kyc`. | تسجيل مزود مكتمل قدر الإمكان + توثيق الحجب. |
| **2. الاستكشاف** | شاشة «كل العروض»، شاشة «دليل المزودين» مع فلترة المدينة والبحث، عرض `portfolios` في صفحة المزود، زر «عرض الكل» للتصنيفات/الخدمات. | استكشاف مطابق للقسم 6 من التقرير. |
| **3. عمليات المزود** ✅ | شاشة ساعات العمل (عرض أسبوعي + إضافة/تعديل بإعادة POST + حذف) واستبدال توجيه زر «ساعات العمل»، مفتاح `toggle-available` منفصل عن `toggle-active`، حقل `service_fee` للمنطقة، نموذج إنشاء طلب B2B، اشتقاق إجمالي الأرباح من `metrics.total_earnings`، واستكمال حقول المعرض. | منجز — راجع تقرير المرحلة 3. |
| **4. العميل** ✅ | إصلاح مسار `/complaint` وربط إنشاء الشكوى وتفاصيلها وردودها، مراجعة فلاتر البحث، ترقيم الحجوزات وكشف الحساب، تدقيق تنقل شاشات العميل، وإصلاح بريد الدعم. | منجز — راجع القسم 8. |
| **5. التحقق والتوثيق** ✅ | `flutter analyze` + `flutter test` + تحديث هذا الملف وسجل التغييرات + تقرير نهائي. | منجز — راجع القسم 9. |

> لن تبدأ أي مرحلة قبل موافقة صريحة على المرحلة السابقة.

---

## 7) نتائج مراجعة ما بعد المرحلة الثالثة (2026-11-11)

| البند | النتيجة المؤكدة | الدليل (قراءة فقط) |
| :--- | :--- | :--- |
| معنى `total_earnings` | مدفوع فقط، وصافي بعد العمولة: `SUM(net_amount)` حيث `status = 'paid'` | `ProviderApiController::dashboard` السطور 73–75 |
| تعديل ساعات العمل | `updateOrCreate` بمفتاح `provider_id + day_of_week` مع قيد `unique` في المهاجرة → تحديث سجل اليوم نفسه، لا تكرار | `storeWorkingHour` + مهاجرة `provider_working_hours` |
| حذف منطقة التغطية | يحذف صف `provider_areas` الخاص بالمزود فقط؛ لا مفاتيح أجنبية تشير إلى `provider_areas.id`، ولا أحداث على النموذج | `destroyArea` + `ProviderArea` + المهاجرة |
| استقلال المفتاحين | `toggle-active` يغيّر `is_active` فقط، و`toggle-available` يغيّر `is_available` فقط؛ كلاهما يعيد الحقلين. اختبار واجهة يثبت أن كل مفتاح يرسل مساره فقط (toggle-available ثم toggle-active) | `toggleServiceActive` / `toggleServiceAvailable` + اختبار `provider_phase3_test.dart` |
| بناء Android | نجح `flutter build apk --debug` بـ Flutter 3.47.9 بعد إعادة محاولة Gradle إثر فشل TLS مؤقت في تنزيل `io.flutter:x86_64_debug`؛ الناتج `build/app/outputs/flutter-apk/app-debug.apk` (~168.5MB). تحذيرات Gradle 8.14 / AGP 8.11.1 / Kotlin 2.2.20 بأن الدعم سيزول قريباً (لم تُعدّل) | سجل البناء |
| الاختبارات | **48/48 نجحت** في تشغيل واحد كامل للحزمة (7 ملفات، منها 8 اختبارات للمرحلة 3) عبر Flutter 3.47.5. `flutter test` على 3.47.9 ينهار في Dart VM قبل تشغيل أي اختبار (حتى القديمة)، رغم نجاح `flutter build` عليه. | سجل التشغيل + رسالة الانهيار أدناه |

**بيئة عطل 3.47.9:** `Flutter 3.47.9 / Dart 3.13.7`, engine `89c39edfdfae2949f6806e4a315c0c08522238b7` (الطابع مطابق لـ `engine.version`) — الانهيار: `Unexpected tag 0 (Nothing) ... Crash occurred when compiling package:_fe_analyzer_shared/src/scanner/scanner.dart_::_scanString in unoptimized JIT mode`. لم تُعدّل ملفات SDK؛ استُخدم SDK بديل موجود مسبقاً (`C:\flutter-sdk`, Flutter 3.47.5 / Dart 3.13.4) لتشغيل الاختبارات.

---

## 8) نتائج المرحلة الرابعة — تجربة العميل (2026-11-11)

| المحور | ما نُفّذ | ما تبقّى |
| :--- | :--- | :--- |
| الشكاوى | زر الشكاوى في الشريط يفتح `/complaints/new`؛ شاشة إنشاء مربوطة بالحجز (`/bookings/{id}/complaint`) وتنتقل للتفاصيل بعد الإنشاء؛ شاشة تفاصيل تعرض `booking.service` و`against.name` والوصف وخيط الردود من الأقدم للأحدث؛ تصميم بطاقات القائمة يعرض الحالة/الأولوية/آخر رد. | `BLOCKED_BY_API`: لا رد/إغلاق من العميل، ولا ترقيم يتجاوز آخر 15 شكوى. |
| البحث | مراجعة الشاشة والفلاتر مقابل `CustomerApiController::search`: تُرسل فقط المعاملات المدعومة، والشريط الافتراضي (0–20,000) لا يُرسل حدوده، والإحداثيات تُرسل فقط عند تفعيل «بالقرب مني»، وترتيب `nearest` مع الإحداثيات. حالة «لا توجد نتائج» + «إعادة ضبط الفلاتر». | لا يوجد قيد API متبقٍ في هذا النطاق. |
| المحفظة وكشف الحساب | الرصيد والملخص من `WalletResource` فقط (`balance/pending_balance/total_credited/total_debited/currency`) دون حقول مخترعة؛ كشف الحساب يستخدم `GET /customer/reports/wallet?page=` (paginator 20/صفحة) مع «عرض X من Y» وتحميل المزيد وإعادة المحاولة؛ شاشة المحفظة تذكر أن `/wallet/transactions` يعيد آخر 20 فقط؛ إشعار صفحة الدفع الوبية خطوةً خارجية ثم تأكيد. | `BLOCKED_BY_API`: لا ترقيم لمسار المعاملات، ولا إتمام دفع داخل التطبيق لأن `checkout_url` جلسة ويب. |
| تجربة العميل والتنقل | تدقيق كل مسارات `push/go` في شاشات العميل مقابل `app_router.dart` — لا مسارات غير معرّفة. إصلاح تبويبات الحجوزات لتستخدم حالات API الفعلية وإضافة ترقيم 15/صفحة (كان تبويب «القادمة» يرسل `upcoming` غير المخزّن). إصلاح بريد شاشة الدعم ليُرسل بريد المستخدم الحقيقي ويتحقق منه بدل `noreply@sahel.app`. توحيد تنسيق المال/التاريخ في `core/utils/format.dart` وتصحيح عرض التواريخ ISO الخام. إصلاح `ListTile` داخل حاوية مزخرفة في الدعم ليبقى تأثير اللمس مرئياً. | — |

**التحقق المنفّذ:**

| الأداة | الإصدار | النتيجة |
| :--- | :--- | :--- |
| `flutter analyze` | Flutter 3.47.9 / Dart 3.13.7 | `No issues found!` |
| `flutter test` (الحزمة كاملة) | Flutter 3.47.5 / Dart 3.13.4 | **57/57 نجحت**، منها 9 اختبارات جديدة في `test/customer_phase4_test.dart` (شكاوى، بحث، محفظة، كشف حساب، حجوزات، دعم). |
| `flutter build apk --debug` | Flutter 3.47.9 | نجح: `build/app/outputs/flutter-apk/app-debug.apk` (~198MB). تحذيرات AGP 8.11.1 وKotlin 2.2.20 بالتقادم فقط، لم تُعدّل. |

**قيود البيئة:** تشغيل الاختبارات على 3.47.9 ينهار في Dart VM قبل تنفيذ أي اختبار (نفس رسالة `Unexpected tag 0 (Nothing)` أعلاه)، لذا استُخدم 3.47.5 للاختبارات فقط. لم يُعدّل أي ملف SDK أو خارج `E:\saber\mobile`، ولم يُعدّل الباك إند أو `routes/api.php` أو الموقع أو قاعدة البيانات.

---

## 9) نتائج المرحلة الخامسة — التحقق النهائي الشامل (2026-11-11)

### 9.1 مراجعة الكود وإصلاحات العقد

| المحور | ما تم تصحيحه |
| :--- | :--- |
| المحادثات | `CustomerRepository.conversation` كان يرمي `messages` السibling من الاستجابة؛ الآن يدمجها في الخريطة، وشاشة المحادثة تعرض السجل الفعلي. شاشة محادثة المزود تعرض تنبيهاً صريحاً لأن `ConversationResource` لا يعرض الرسائل. |
| عدّاد الإشعارات | `/customer/notifications/unread` يعيد `unread_count` وليس قائمة؛ أُضيف `unreadNotificationsCount()` و`unreadNotificationsProvider` أصبح `FutureProvider<int>`، وشاشة الرئيسية تستخدم العدد الحقيقي. |
| الملف الشخصي للمزود | `GET /provider/profile` يعيد `{provider, user}` متداخلين؛ أُضيف `providerProfileFields()` لتسوية الشكل، واستُخدم في إعدادات المزود ونموذج B2B (معرّف المزود الحقيقي بدل `0`). |
| KYC | قراءة `{is_verified, verification_status, latest_request}` مع `latest_request.notes/documents` ودعم الوثائق النصية، ورسالة واضحة عند الاعتماد دون وثائق. |
| التقييمات | `ReviewResource` يستخدم `review` وليس `comment`؛ صُحّح في شاشتي تقييمات المزود وصفحة المزود العامة، واسم المقيّم من `customer.name`، مع توضيح أن رد المزود غير معروض من الـ API. |
| الحجوزات | مفتاح وقت التقويم أصبح `booking_time` أولاً؛ عنوان الدفع يستخدم `booking_number`؛ زر حجز الخدمة يمرر كائن `Service` عبر `extra` ليتجاوز حد `/services` العام (12 افتراضياً)؛ معالج الحجز يقبل `initialService` بدل الاعتماد على أول صفحة. |
| الخدمات والصور | صور الخدمة تقرأ من قائمة `asList` (وليس `dataList` الذي يحوّل العناصر لخرائط)، مع بديل `business_cover` لصورة المزود؛ طلبات `/services` تطلب `limit=50` لأن الفلاتر العامة يتجاهلها الباك إند. |
| البحث | الكلمات الشائعة تُقرأ من `query`، ورابط البحث بالتصنيف يستخدم `category` المدعوم في `/customer/search`. |
| الملاحظات والإشعارات | تعليم إشعار المزود كمقروء عند اللمس مع تحديث القائمة؛ تعليم الكل في العميل يتم فردياً لأن `read-all` غير موجود للعميل. |
| السحب والأرباح | رسائل فشل السحب تستخرج `ApiException/ServerFailure/ValidationFailure`، والرصيد ينسّق بالعملة مع توضيح أن `balance` ليس بالضرورة «المتاح» (الباك إند يتحقق من `available_balance` غير المعروض). |
| رفض الطلبات | سبب الرفض أصبح إلزامياً في الواجهة (طلب والباك إند يرفض الفراغ عبر قاعدة `different:`). |
| التنقل والأدوار | حاجز التوجيه يمنع المزود من فتح أي مسار عميل عبر رابط عميق (كان يغطي الجذور الخمسة فقط)؛ أُضيفت مسارات `/p/settings/language` و`/p/settings/currency` بعد إغلاق `/settings/*` على المزود، ورُبط زر اللغة بها. حماية `/p/services/edit` من `extra` فارغ. |
| الواجهة العامة | إصدار splash يُقرأ من `package_info_plus` بدل نص ثابت؛ ملاحظة أن صور الخدمة غير قابلة للتعديل عبر API بدل نص مشوّه. |
| البناء | `android/build.gradle` يوحّد `desugar_jdk_libs` على 2.1.4 المخزّنة، بعد تعذّر تنزيل 1.2.2 المطلوبة من `flutter_local_notifications` لتعذر الوصول إلى `dl.google.com` من JVM الخاص بـ Gradle. لا تغيير في سلوك التطبيق. |

### 9.2 التحليل والاختبارات

| الأداة | الإصدار | النتيجة |
| :--- | :--- | :--- |
| `flutter analyze` | Flutter 3.47.9 / Dart 3.13.7 | `No issues found!` (4.9s ثم 8.9s بعد آخر تعديل) |
| `flutter test` (الحزمة كاملة) | Flutter 3.47.5 / Dart 3.13.4 | **57/57 نجحت** قبل وبعد آخر تعديلات الحزمة. تشمل اختبارات التسجيل/الوثائق، التحقق من الحالة، الشكاوى، البحث، المحفظة، ساعات العمل، B2B، والصفحات الجديدة. |

### 9.3 بناء APK والتحقق منه

| البند | القيمة |
| :--- | :--- |
| الأمر | `flutter build apk --release` |
| Flutter / Dart | 3.47.9 / 3.13.7 |
| المسار | `E:\saber\mobile\build\app\outputs\flutter-apk\app-release.apk` |
| الحجم | 70,955,678 بايت (67.7 MB) |
| SHA-256 | `27b22389a75207c77493266941b725cf4b0d7a479d7c729de58a1d72d408aafe` |
| الحزمة / الإصدار | `com.sahel.app.saber_flutter` — `versionName=1.0.0`, `versionCode=421` |
| SDK | `minSdk=24`, `targetSdk=36`, `compileSdk=36` |
| التوقيع | APK Signature Scheme v2 ناجح؛ الشهادة **Android Debug** لأن `build.gradle` يوقّع release بمفتاح debug افتراضياً. **مطلوب مفتاح إنتاج قبل النشر.** |
| سلامة الأرشيف | `unzip -t` — `No errors detected`. |
| التثبيت والتشغيل | نُصّب على محاكي Android 15 (API 35) بنجاح، وبدأ النشاط `MainActivity` وبقي التطبيق في المقدمة دون انهيار. لقطات: `build/emulator_app.png` (تسجيل الدخول RTL) و`build/emulator_register.png`/`emulator_register_provider.png` (التسجيل وقسم وثائق المزود). |

### 9.4 الاختبار العملي — ما نُفّذ وما تعذّر

| الوظيفة | الحالة العملية |
| :--- | :--- |
| تثبيت APK وتشغيله | ✅ نُفّذ فعلياً على محاكي API 35؛ يفتح شاشة الدخول العربية RTL. |
| التنقل إلى التسجيل واختيار الدور | ✅ نُفّذ فعلياً؛ بطاقة «مزود خدمة» تُظهر قسم «ملف مزود الخدمة» وزر اختيار الوثائق. |
| التسجيل/الدخول/OTP/استعادة الجلسة | ⛔ لم يُنفّذ عملياً: الباك إند غير متاح (`http://127.0.0.1:8000` و`http://10.0.2.2:8000` أعادا `000`). مغطّى باختبارات واجهة فقط، ولم تُدّعَ نجاحات حقيقية. |
| رفع وثائق المزود | ⛔ يحتاج جلسة/API؛ الواجهة تظهر لكن الإرسال لم يُختبر عملياً. |
| الخدمات/البحث/الفلاتر/العروض | ⛔ تحتاج API؛ مغطاة باختبارات واجهة ومراجعة عقد. |
| الحجز/التتبع/التقييم/الشكاوى/B2B/المعرض | ⛔ تحتاج API؛ مغطاة باختبارات ومراجعة عقود. |
| محفظة المزود/الأرباح/السحب | ⛔ تحتاج API. |
| حالات التحميل/الخطأ/الفراغ | ✅ ظاهرة في الكود والاختبارات؛ عملياً ظهرت شاشة الدخول سليمة، ولم يمكن الوصول لبيانات فارغة حقيقية دون API. |
| قيود إضافية | لا توجد أجهزة Android فعلية؛ المحاكي أُنشئ مؤقتاً (خارج المشروع) ثم أُزيل بعد الاختبار. محاولة أولى بلا نافذة انتهت بـ segfault، ونجحت المحاولة بنافذة. |

### 9.5 المتبقي والقيود النهائية

- ترقيم قوائم المزود (خدمات/حجوزات/طلبات/تقييمات/سحوبات) غير منفّذ في الواجهة؛ تعرض الصفحة الأولى (15) فقط رغم وجود `meta` في الاستجابة.
- لا هوية اسم للعميل في حجز المزود (يمكن عرض الهاتف من `address` إن وُجد)؛ لا مرفقات للحجز؛ لا سجل رسائل لمحادثة المزود؛ لا `provider_reply` في التقييم.
- عميل الشكاوى بلا رد/إغلاق ولا ترقيم أبعد من 15.
- لا `GET /services/{slug}` مستقل؛ التفاصيل تُستنتج من قائمة تصل إلى 50 خدمة، مع تمرير الكائن من الرئيسية لتجاوز الحد.
- `/services` العامة تتجاهل `q/category_id/sort/page`؛ البحث الحقيقي عبر `/customer/search`.
- APK موقّع بمفتاح debug وإعداداته الحالية؛ لا يصلح للنشر قبل إعداد keystore إنتاج.
- لم يُعدّل الباك إند أو `routes/api.php` أو قاعدة البيانات أو الموقع أو أي SDK.
