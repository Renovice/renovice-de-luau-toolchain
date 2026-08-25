@echo off
setlocal
cd /d "%~dp0\..\.."
if not exist "bin" mkdir "bin"
call "tools\warframe_api\build_catalog.bat"
if errorlevel 1 exit /b 1
g++ -std=c++17 -O2 -Wall -Wextra -Werror -static -o "bin\wf_api_check.exe" "tools\warframe_api\wf_api_check.cpp"
if errorlevel 1 exit /b 1
"bin\wf_api_check.exe" "api\warframe\contracts.tsv" "cert\warframe_api\src\wf_radial_numeric_damage_callback.luau"
if errorlevel 1 exit /b 1
"bin\wf_api_check.exe" "api\warframe\contracts.tsv" "tools\warframe_api\tests\valid_catalog_contracts.luau"
if errorlevel 1 exit /b 1
"bin\wf_api_check.exe" "api\warframe\contracts.tsv" "tools\warframe_api\tests\invalid_contracts.luau" >nul
if not errorlevel 1 (
  echo [wf_api] FAIL: invalid callback/method arities were accepted
  exit /b 1
)
"bin\wf_api_check.exe" "api\warframe\contracts.tsv" "tools\warframe_api\tests\invalid_catalog_contracts.luau" >nul
if not errorlevel 1 (
  echo [wf_api] FAIL: invalid high-confidence catalog arities were accepted
  exit /b 1
)
echo [wf_api] checker build and smoke test PASS
exit /b 0
