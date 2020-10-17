@echo off
setlocal
call :check yosys.exe || goto error
call :check nextpnr-ecp5.exe || goto error
call :check ecppack.exe || goto error
call :check fujprog.exe || goto error
set SRC=%1
set LPF=%2
if "%SRC%" == "" goto usage
if "%LPF%" == "" set LPF=ulx3s.lpf
if not exist %SRC% set SRC=%SRC%.v
if not exist %SRC% goto nofile

set SRCBASE=%~n1

echo ====== Yosys =========
yosys.exe -q -p "synth_ecp5 -json %SRCBASE%.json"  %SRCBASE%.v || goto error
echo ====== NextPNR =======
nextpnr-ecp5.exe --quiet --randomize-seed --85k --json %SRCBASE%.json --package CABGA381 --textcfg %SRCBASE%.config --lpf %LPF%
echo ====== Packing and flashing ========
ecppack.exe %SRCBASE%.config %SRCBASE%.bit || goto error
fujprog.exe %SRCBASE%.bit || goto error
echo ======== Done ========
exit /b 0

:usage
echo Usage: %0 sourcefile.v [sourcefile.lpf]
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
