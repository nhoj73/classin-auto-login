@echo off
chcp 65001 >nul
cd /d "%~dp0"
powershell -STA -ExecutionPolicy Bypass -File "%~dp0capture_coords.ps1"
pause
