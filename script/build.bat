@echo off
chcp 65001

if not exist node_modules (
  call npm i
)

if not exist output (
  mkdir output
)


if not exist output\windows (
  mkdir output\windows
)

echo.
echo =======================
echo "build for windows"
echo =======================
echo.

:: total package number
set /A index=1
for /f %%a in (' find /c /v "" ^<"app.csv" ') do set /A total=%%a
:: ignore first header line
set /A total=total-1

set old_name=weread
set old_title=WeRead
set old_zh_name=????
set old_url=https://weread.qq.com/

:: for windows, we need replace package name to title
.\script\sd.exe "\"productName\": \"weread\"" "\"productName\": \"WeRead\"" src-tauri\tauri.conf.json

for /f "skip=1 tokens=1-4 delims=," %%i in (app.csv) do (
  setlocal enabledelayedexpansion
  set name=%%i
  set title=%%j
  set name_zh=%%k
  set url=%%l
  @echo on

  ::echo name is !name! !name_zh!  !url!
  :: replace url
  .\script\sd.exe !old_url! !url! src-tauri\tauri.conf.json
  ::replace  pacakge name
  .\script\sd.exe !old_title! !title! src-tauri\tauri.conf.json
  .\script\sd.exe !old_name! !name! src-tauri\tauri.conf.json
  echo update ico with 32x32 pictue
  .\script\sd.exe !old_name! !name! src-tauri\src\main.rs
  ::copy src-tauri\png\!name!_32.ico src-tauri\icons\icon.ico
  echo.
  ::update package info
  set old_zh_name=!name_zh!
  set old_name=!name!
  set old_title=!title!
  set old_url=!url!
  ::build package
  echo building package !index!/!total!
  echo package name is !name! !name_zh!
  echo npm run build:windows
  @echo off
  call npm run tauri build -- --target x86_64-pc-windows-msvc
  move src-tauri\target\x86_64-pc-windows-msvc\release\bundle\msi\*.msi output\windows

  @REM ?? exe ????????
  if not exist output\windows\!name! (
    mkdir output\windows\!name!
  )
  move src-tauri\target\x86_64-pc-windows-msvc\release\deps\app.exe output\windows\!name!

  @echo on
  echo package build success!
  echo.
  echo.

  set /A index=index+1
  @echo off

)

:: for windows, we need replace package name to lower again
.\script\sd.exe "\"productName\": \"WeRead\"" "\"productName\": \"weread\"" src-tauri\tauri.conf.json
echo "output dir is output\windows"
