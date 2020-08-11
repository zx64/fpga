@echo off
setlocal
cd /d %~dp0
powershell -NonInteractive -NoLogo -NoProfile .\update.ps1
pause
