@echo off
setlocal
cd /d "%~dp0\..\.."
if not exist "bin" mkdir "bin"
rem PATH AUTHORITY: resolve the audited census through WORKSPACE.json
rem (protected.research + the census folder). RENOVICE_WORKSPACE_ROOT and
rem RENOVICE_CENSUS_SITES override for isolated reproduction. The old
rem "..\RESEARCH\..." relative path was broken (no such sibling) and is NOT
rem a supported fallback.
set "WS_ROOT=%RENOVICE_WORKSPACE_ROOT%"
if "%WS_ROOT%"=="" for %%I in ("%CD%\..\..\..") do set "WS_ROOT=%%~fI"
if "%WS_ROOT:~-1%"=="\" set "WS_ROOT=%WS_ROOT:~0,-1%"
set "CENSUS_SITES=%RENOVICE_CENSUS_SITES%"
if "%CENSUS_SITES%"=="" set "CENSUS_SITES=%WS_ROOT%\RESEARCH\DE LUAU TRANSLATOR\NATIVE API AND LIVE CANDIDATE CENSUS\result_consumption_sites.tsv"
if not exist "%CENSUS_SITES%" (
  echo [wf_api] FAIL: audited census not found at "%CENSUS_SITES%"
  exit /b 1
)
g++ -std=c++17 -O2 -Wall -Wextra -Werror -static -o "bin\wf_api_catalog.exe" "tools\warframe_api\wf_api_catalog.cpp"
if errorlevel 1 exit /b 1
"bin\wf_api_catalog.exe" ^
  "api\warframe\selection_seeds.tsv" ^
  "%CENSUS_SITES%" ^
  "api\warframe\contracts.tsv" ^
  "api\warframe\selected_catalog.tsv"
if errorlevel 1 exit /b 1
echo [wf_api] catalog build PASS
exit /b 0
