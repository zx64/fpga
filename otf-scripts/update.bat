@echo off
setlocal
call :check pwsh.exe || goto error
call :check 7z.exe || goto error
call :check curl.exe || goto error
cd /d %~dp0
pwsh.exe -NonInteractive -NoLogo -NoProfile .\update.ps1
pause
exit /b 0

:check
where /Q %1
if ERRORLEVEL 1 echo Could not find %1
goto :eof

:error
pause
exit /b 1
