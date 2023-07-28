@echo off

cd /d %~dp0

set HERE=%~dp0

set BUSYBOX="%HERE%App\Utils\busybox.exe"
set CURL="%HERE%App\Utils\curl.exe"
set SZIP="%HERE%App\Utils\7za.exe"

:::::: NETWORK CHECK

%CURL% -I -s www.google.com | %BUSYBOX% grep -q "403"

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

%CURL% -I -k -s https://github.com/ungoogled-software/ungoogled-chromium-windows/releases/latest | %BUSYBOX% grep -o tag/[0-9.]\+[0-9]\-[0-9.]\+[0-9] | %BUSYBOX% cut -d "/" -f2 > version.txt

for /f %%V in ('more version.txt') do (set VERSION=%%V)
echo Latest: %VERSION%

if exist "version.txt" del "version.txt" > NUL

::::::::::::::::::::

:::::: RUNNING PROCESS CHECK

if not exist tasklist goto GET

for /f %%C in ('tasklist /NH /FI "IMAGENAME eq chrome.exe"') do if %%C == chrome.exe (
  echo Close Cromium To Update
  pause
  exit
)

::::::::::::::::::::

:GET

:::::: GET LATEST VERSION

if exist "TMP" rmdir "TMP" /s /q
mkdir "TMP"

set UCHROM="https://github.com/ungoogled-software/ungoogled-chromium-windows/releases/download/%VERSION%/ungoogled-chromium_%VERSION%_windows_%ARCH%.zip"

%CURL% -k -L %UCHROM% -o TMP\UChromium_%VERSION%_%ARCH%.zip

::::::::::::::::::::

:::::: UNPACKING

if exist "App\UChromium" rmdir "App\UChromium" /s /q

%SZIP% x -aoa TMP\UChromium_%VERSION%_%ARCH%.zip -o"TMP\" > NUL

robocopy /MOVE /S TMP\ungoogled-chromium_%VERSION%_windows App\UChromium /NFL /NDL /NJH /NJS

::::::::::::::::::::

:::::: WIDEVINE CDM

set WIDEVINE="https://github.com/Numstr/UChromium/raw/main/WidevineCdm/WidevineCdm_%ARCH%.zip"
:: https://dl.google.com/widevine-cdm/4.10.2449.0-win-%ARCH%.zip

echo Get Widevine Cdm

%CURL% -k -L %WIDEVINE% -o TMP\WidevineCdm_%ARCH%.zip

%SZIP% x -aoa TMP\WidevineCdm_%ARCH%.zip -o"App\UChromium\WidevineCdm" > NUL

rmdir "TMP" /s /q

::::::::::::::::::::

echo Done

pause
