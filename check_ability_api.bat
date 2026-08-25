@echo off
setlocal
cd /d "%~dp0"
if "%~1"=="" (
  echo Usage: check_ability_api.bat source.luau [--show-unknown^|--strict-unknown]
  exit /b 2
)
if not exist "bin\wf_api_check.exe" (
  call "tools\warframe_api\build_checker.bat"
  if errorlevel 1 exit /b 1
)
echo [1/2] DE compile/reparse check
set "WFAPI_COMPILE_INPUT=%TEMP%\wf_api_check_%RANDOM%_%RANDOM%.luau"
copy /y "%~f1" "%WFAPI_COMPILE_INPUT%" >nul
if errorlevel 1 (
  echo [wf_api] failed to stage the source at a short compiler path
  exit /b 1
)
"bin\derecomp.exe" recompile "%WFAPI_COMPILE_INPUT%" NUL
set "WFAPI_COMPILE_RESULT=%ERRORLEVEL%"
if not "%WFAPI_COMPILE_RESULT%"=="0" (
  del /q "%WFAPI_COMPILE_INPUT%" >nul 2>nul
  exit /b %WFAPI_COMPILE_RESULT%
)
echo [2/2] Focused Warframe API contract check
"bin\wf_api_check.exe" "api\warframe\contracts.tsv" "%WFAPI_COMPILE_INPUT%" %2
set "WFAPI_CHECK_RESULT=%ERRORLEVEL%"
del /q "%WFAPI_COMPILE_INPUT%" >nul 2>nul
if not "%WFAPI_CHECK_RESULT%"=="0" exit /b %WFAPI_CHECK_RESULT%
echo [wf_api] focused script check PASS - perform the in-game test next
exit /b 0
