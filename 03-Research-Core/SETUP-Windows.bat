@echo off
chcp 65001 >nul 2>&1
title FreeMind Core - One-Time Setup
cd /d "%~dp0"
echo.
echo  ==================================================
echo    FreeMind Core  --  SETUP (run ONCE, needs internet)
echo    الإعداد لمرة واحدة فقط - يتطلب اتصال إنترنت
echo  ==================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "SETUP.ps1"
echo.
echo  Press any key to close / اضغط أي مفتاح للإغلاق
pause >nul
