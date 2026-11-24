@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\reset_db.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"
if not "%CI%"=="true" if "%NO_PAUSE%"=="" pause
exit /b %EXIT_CODE%
