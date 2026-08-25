@echo off
setlocal
cd /d "%~dp0\..\.."
if not exist "bin" mkdir "bin"
g++ -std=c++17 -O2 -Wall -Wextra -Werror -static -o "bin\wf_api_catalog.exe" "tools\warframe_api\wf_api_catalog.cpp"
if errorlevel 1 exit /b 1
"bin\wf_api_catalog.exe" ^
  "api\warframe\selection_seeds.tsv" ^
  "..\RESEARCH\DE LUAU TRANSLATOR\NATIVE API AND LIVE CANDIDATE CENSUS\result_consumption_sites.tsv" ^
  "api\warframe\contracts.tsv" ^
  "api\warframe\selected_catalog.tsv"
if errorlevel 1 exit /b 1
echo [wf_api] catalog build PASS
exit /b 0
