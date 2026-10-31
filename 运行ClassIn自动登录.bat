@echo off
chcp 65001 >nul
cd /d "%~dp0"
powershell -STA -ExecutionPolicy Bypass -File "%~dp0classin_auto_login.ps1"
pause
