@echo off
setlocal EnableExtensions
chcp 65001 >nul 2>&1
title DevCompanion - Stop Engine
cd /d "%~dp0"

set "PORT=8802"
if exist "config\settings.conf" (
  for /f "usebackq eol=# delims== tokens=1,*" %%a in ("config\settings.conf") do (
    if /i "%%a"=="PORT" set "PORT=%%b"
  )
)

echo Stopping DevCompanion engine on port %PORT% ...
set "FOUND="
for /f "tokens=5" %%p in ('netstat -ano ^| findstr /c:":%PORT% " ^| findstr /c:"LISTENING"') do (
  set "FOUND=1"
  taskkill /PID %%p /F >nul 2>&1 && echo   [OK] Stopped process %%p
)
if not defined FOUND echo   [i] No running engine found on port %PORT%
echo Done / تم.
timeout /t 5 >nul
