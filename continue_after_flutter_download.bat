@echo off
REM ==================================================================
REM  ساحل (Sahel) Mobile Flutter App — الخطوات بعد اكتمال تنزيل SDK
REM  شغّل هذا الملف بمجرد اكتمال تنزيل وفك ضغط Flutter SDK
REM ==================================================================
chcp 65001 > nul
title Sahel Flutter Setup

echo.
echo ============================================================
echo   ساحل - إعداد وتشغيل تطبيق Flutter (الخطوة ٢)
echo ============================================================
echo.

REM ---------- ١. التأكد من وجود Flutter في PATH ----------
where flutter >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo [١/٦] إضافة Flutter إلى PATH للجلسة الحالية...
    IF EXIST "C:\src\flutter\bin\flutter.bat" (
        set "PATH=C:\src\flutter\bin;%PATH%"
        echo       تم إضافة C:\src\flutter\bin بنجاح
    ) ELSE (
        echo       ❌ لم يتم العثور على C:\src\flutter\bin
        echo       قم بتثبيت Flutter SDK أولاً ثم عد لتشغيل هذا الملف.
        pause
        exit /b 1
    )
)

echo.
echo [٢/٦] التحقق من إصدار Flutter...
flutter --version

echo.
echo [٣/٦] الانتقال إلى مجلد المشروع: e:\saber\mobile
cd /d "e:\saber\mobile"

echo.
echo [٤/٦] تنزيل التبعيات (flutter pub get)...
flutter pub get
IF %ERRORLEVEL% NEQ 0 (
    echo       ❌ فشل في تنزيل التبعيات. تحقق من الاتصال.
    pause
    exit /b 1
)

echo.
echo [٥/٦] توليد ملفات الكود التلقائية (.g.dart - Drift, Retrofit, Freezed)...
dart run build_runner build --delete-conflicting-outputs
IF %ERRORLEVEL% NEQ 0 (
    echo       ⚠  فشل توليد بعض الملفات (غالباً لا يمنع التشغيل الأول)
)

echo.
echo [٦/٦] فحص الأخطاء البرمجية...
dart analyze

echo.
echo ============================================================
echo   ✅ تم إعداد المشروع بنجاح!
echo ============================================================
echo.
echo   ▶ لتشغيل نسخة العميل (على متصفح الويب Chrome/Edge):
echo      flutter run -d chrome -t lib\main_customer.dart --web-port=5173
echo.
echo   ▶ لتشغيل نسخة مقدم الخدمة:
echo      flutter run -d chrome -t lib\main_provider.dart --web-port=5174
echo.
echo   ▶ لعرض قائمة الأجهزة المتاحة:
echo      flutter devices
echo.
pause
