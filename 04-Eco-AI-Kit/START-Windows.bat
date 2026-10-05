@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul 2>&1
title EcoAI - Local AI Engine
cd /d "%~dp0"

echo.
echo  ==================================================
echo    EcoAI  --  المساعد الشامل المتنقل
echo    Eco-AI Portable Kit  (Offline / Air-Gapped)
echo  ==================================================
echo.

:: ---------- قراءة الإعدادات ----------
set "PORT=8804"
set "CTX=4096"
set "GPU=AUTO"
set "THREADS=0"
set "MDLTEMP=0.7"
set "MODEL_FILE=AUTO"
set "EXTRA=--jinja"

if exist "config\settings.conf" (
  for /f "usebackq eol=# delims== tokens=1,*" %%a in ("config\settings.conf") do (
    if /i "%%a"=="PORT" set "PORT=%%b"
    if /i "%%a"=="CONTEXT_SIZE" set "CTX=%%b"
    if /i "%%a"=="GPU_LAYERS" set "GPU=%%b"
    if /i "%%a"=="THREADS" set "THREADS=%%b"
    if /i "%%a"=="TEMPERATURE" set "MDLTEMP=%%b"
    if /i "%%a"=="MODEL_FILE" set "MODEL_FILE=%%b"
    if /i "%%a"=="EXTRA_ARGS" set "EXTRA=%%b"
  )
)

:: ---------- حماية من القيم الفارغة ----------
if "%PORT%"=="" set "PORT=8804"
if "%CTX%"=="" set "CTX=4096"
if "%MDLTEMP%"=="" set "MDLTEMP=0.7"
if "%THREADS%"=="" set "THREADS=0"
if "%MODEL_FILE%"=="" set "MODEL_FILE=AUTO"

:: ---------- البحث عن النموذج ----------
set "MODEL="
if /i not "%MODEL_FILE%"=="AUTO" (
  if exist "models\%MODEL_FILE%" set "MODEL=%MODEL_FILE%"
)
if not defined MODEL (
  for /f "delims=" %%f in ('dir /b /o-s "models\*.gguf" 2^>nul') do if not defined MODEL set "MODEL=%%f"
)
if not defined MODEL (
  echo  [X] NO MODEL FILE FOUND / لا يوجد نموذج
  echo      Run SETUP-Windows.bat first  -or-  copy any .gguf
  echo      file into the "models" folder.
  echo      See: docs\README.md
  echo.
  pause
  exit /b 1
)
echo  [+] Model : %MODEL%

:: ---------- البحث عن المحرك ----------
set "ENGINE="
if exist "bin\win\llama-server.exe" set "ENGINE=bin\win\llama-server.exe"
if not defined ENGINE (
  for /r "bin" %%f in (llama-server.exe) do if not defined ENGINE set "ENGINE=%%f"
)
if not defined ENGINE (
  echo  [X] ENGINE NOT FOUND / لم يتم العثور على المحرك
  echo      Run SETUP-Windows.bat to download llama.cpp
  echo      (needs internet ONCE), or see docs\TECHNICAL.md
  echo.
  pause
  exit /b 1
)
echo  [+] Engine: %ENGINE%

:: ---------- هل المحرك يعمل مسبقاً؟ ----------
curl -s -m 3 -o nul "http://127.0.0.1:%PORT%/health" 2>nul
if not errorlevel 1 (
  echo  [i] Engine already running on port %PORT%
  goto :openui
)

:: ---------- تشغيل المحرك ----------
if not exist logs mkdir logs
set "SRVARGS=-m models\%MODEL% --host 127.0.0.1 --port %PORT% -c %CTX% --temp %MDLTEMP%"
if %THREADS% GTR 0 set "SRVARGS=%SRVARGS% -t %THREADS%"
if "%GPU%"=="0" set "SRVARGS=%SRVARGS% -ngl 0"
if not "%EXTRA%"=="" set "SRVARGS=%SRVARGS% %EXTRA%"

echo  [+] Starting engine  (context=%CTX%  port=%PORT%) ...
start "AI Engine" /min cmd /c ""%ENGINE%" %SRVARGS% > "logs\engine.log" 2>&1"

echo  [..] Loading model - large models may take 1-5 minutes
echo       (شريطة تحميل النموذج - انتظر من دقيقة إلى خمس)
set /a TRIES=0

:waitloop
timeout /t 2 /nobreak >nul
curl -s -m 3 "http://127.0.0.1:%PORT%/health" 2>nul | find /i "ok" >nul
if not errorlevel 1 goto :ready
set /a TRIES+=1
if %TRIES% LSS 150 goto :waitloop

echo  [X] Engine did not become ready in 5 minutes. Last log lines:
echo  ------------------------------------------------------
powershell -NoProfile -Command "Get-Content 'logs\engine.log' -Tail 25" 2>nul
echo  ------------------------------------------------------
echo  Common causes: not enough RAM, corrupted model file,
echo  or the model needs a GPU. See docs\README.md (troubleshooting)
echo.
pause
exit /b 1

:ready
echo  [OK] Engine ready:  http://127.0.0.1:%PORT%

:openui
> "ui\port.js" echo window.LAUNCH_PORT=%PORT%;
start "" "ui\index.html"
echo  [OK] Interface opened in your browser / فُتحت الواجهة
echo.
echo   - STOP the engine : run STOP-Windows.bat
echo   - Engine log      : logs\engine.log
echo   - This window may be closed now / يمكن إغلاق النافذة
echo.
timeout /t 12 >nul
