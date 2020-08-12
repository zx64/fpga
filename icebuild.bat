@echo off
setlocal
call :check yosys.exe || goto error
call :check nextpnr-ice40.exe || goto error
call :check icepack.exe || goto error
call :check icefunprog.exe || goto error
set SRC=%1
set PCF=%2
if "%SRC%" == "" goto usage
if "%PCF%" == "" set PCF=iceFUN.pcf
if not exist %SRC% set SRC=%SRC%.v
if not exist %SRC% goto nofile

set SRCBASE=%~n1

echo ====== Yosys =========
yosys.exe -q -p "synth_ice40 -json %SRCBASE%.json"  %SRCBASE%.v || goto error
echo ====== NextPNR =======
nextpnr-ice40.exe --quiet --randomize-seed --hx8k --json %SRCBASE%.json --package cb132 --asc %SRCBASE%.asc --opt-timing --pcf %PCF%
echo ====== Packing and flashing ========
icepack.exe %SRCBASE%.asc %SRCBASE%.bin || goto error
if "%ICEFUNPORT%" == "" (
    echo set ICEFUNPORT=COMx e.g. COM3 first.
    goto error
)
iceFUNprog.exe %ICEFUNPORT% %SRCBASE%.bin || goto error
echo ======== Done ========
exit /b 0

:usage
echo Usage: %0 sourcefile.v [sourcefile.pcf]
pause
exit /b 1

:check
where /Q %1
if ERRORLEVEL 1 echo Could not find %1
goto :eof

:nofile
echo File %SRC% not found
goto error

:error
pause
exit /b 1
