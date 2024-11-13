@echo off

cd /d %~dp0

set HERE=%~dp0

set BUSYBOX="%HERE%App\Utils\busybox.exe"
set SZIP="%HERE%App\Utils\7za.exe"

:::::: NETWORK CHECK

%BUSYBOX% wget -q --user-agent="Mozilla" --spider https://google.com

if "%ERRORLEVEL%" == "1" (
  echo Check Your Network Connection
  pause
  exit
)

::::::::::::::::::::

:::::: ARCH

if "%PROCESSOR_ARCHITECTURE%" == "x86" (
  set ARCH=x86
) else if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
  set ARCH=x64
) else exit

:: set ARCH=x86
:: set ARCH=x64

::::::::::::::::::::

:::::: VERSION CHECK

%BUSYBOX% wget -q -O - https://github.com/ungoogled-software/ungoogled-chromium-windows/releases/latest | %BUSYBOX% grep -o tag/[0-9.]\+[0-9]\-[0-9.]\+[0-9] | %BUSYBOX% cut -d "/" -f2 > version.txt

for /f %%V in ('more version.txt') do (set VERSION=%%V)
echo Latest: %VERSION%
echo:

if exist "version.txt" del "version.txt" > NUL

::::::::::::::::::::

:::::: RUNNING PROCESS CHECK

if not exist "%WINDIR%\system32\tasklist.exe" goto GET

for /f %%C in ('tasklist /NH /FI "IMAGENAME eq uchrome.exe"') do if %%C == uchrome.exe (
  echo Close UCromium To Update
  pause
  exit
)

::::::::::::::::::::

:GET

:::::: GET LATEST VERSION

if exist "TMP" rmdir "TMP" /s /q
mkdir "TMP"

set UCHROM="https://github.com/ungoogled-software/ungoogled-chromium-windows/releases/download/%VERSION%/ungoogled-chromium_%VERSION%_windows_%ARCH%.zip"

%BUSYBOX% wget %UCHROM% -O TMP\UChromium_%VERSION%_%ARCH%.zip

::::::::::::::::::::

:::::: UNPACKING

echo:
echo Unpacking

if exist "App\UChromium" rmdir "App\UChromium" /s /q

%SZIP% x -aoa TMP\UChromium_%VERSION%_%ARCH%.zip -o"TMP\" > NUL

robocopy /MOVE /S TMP\ungoogled-chromium_%VERSION%_windows_%ARCH% App\UChromium /NFL /NDL /NJH /NJS

if exist "App\UChromium\chrome.exe" ren "App\UChromium\chrome.exe" "uchrome.exe"

::::::::::::::::::::

:::::: WIDEVINE CDM

set WIDEVINE="https://github.com/Numstr/UChromium/raw/main/WidevineCdm/WidevineCdm_%ARCH%.zip"
:: https://dl.google.com/widevine-cdm/4.10.2449.0-win-%ARCH%.zip

echo Get Widevine Cdm
echo:

%BUSYBOX% wget %WIDEVINE% -O TMP\WidevineCdm_%ARCH%.zip

echo:
echo Unpacking

%SZIP% x -aoa TMP\WidevineCdm_%ARCH%.zip -o"App\UChromium\WidevineCdm" > NUL

rmdir "TMP" /s /q

::::::::::::::::::::

echo:

echo Done

pause
