@echo off
setlocal
set SRC=%1
set PCF=%2
if "%SRC%" == "" goto usage
if "%PCF%" == "" set PCF=iceFUN.pcf
if not exist %SRC% set SRC=%SRC%.v
if not exist %SRC% goto nofile

if not exist c:\fpga (
    goto notoolchain
)

set TOOLCHAIN=C:\fpga\bin
set SRCBASE=%~n1

echo ====== Yosys =========
%TOOLCHAIN%\yosys.exe -q -p "synth_ice40 -json %SRCBASE%.json"  %SRCBASE%.v || goto error
echo ====== NextPNR =======
%TOOLCHAIN%\nextpnr-ice40.exe --quiet --randomize-seed --hx8k --json %SRCBASE%.json --package cb132 --asc %SRCBASE%.asc --opt-timing --pcf %PCF%
echo ====== Packing and flashing ========
%TOOLCHAIN%\icepack.exe %SRCBASE%.asc %SRCBASE%.bin || goto error
if "%ICEPORT%" == "" (
    echo set ICEPORT=COMx e.g. COM3 first.
    goto error
)
iceFUNprog.exe %ICEPORT% %SRCBASE%.bin || goto error
echo ======== Done ========
exit /b 0

:usage
echo Usage: %0 sourcefile.v
pause
exit /b 1

:notoolchain
echo Download latest https://github.com/open-tool-forge/fpga-toolchain and unpack into c:\fpga
goto error

:nofile
echo File %SRC% not found
goto error

:error
pause
exit /b 1
