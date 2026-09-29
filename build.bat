@echo off
REM DeNativeRecompiler build -> bin\derecomp.exe  (msys2 ucrt64 g++)
setlocal
set "GPP=C:\msys64\ucrt64\bin\g++.exe"
cd /d "%~dp0"
if not exist bin mkdir bin
REM -static: no external DLL deps -> derecomp.exe is truly self-contained (serves the one-folder goal)
REM --no-insert-timestamp makes the PE artifact reproducible; otherwise two identical source builds
REM receive different hashes solely from the linker timestamp and cannot match certification docs.
"%GPP%" -O2 -std=c++17 -Wall -Werror -static -static-libgcc -static-libstdc++ -Wl,--no-insert-timestamp -o bin\derecomp.exe src\main.cpp
if errorlevel 1 ( echo BUILD FAILED & exit /b 1 )
bin\derecomp.exe transcode-global-selftest
if errorlevel 1 ( echo GLOBAL LOWERING SELFTEST FAILED & exit /b 1 )
"%GPP%" -O2 -std=c++17 -Wall -Wextra -Werror -static -Isrc -o bin\verify-shared-string-values.exe RESEARCH\SHARED_STRING_CONSTANTS_2026-09-15\tools\verify_constant_use.cpp
if errorlevel 1 ( echo SHARED STRING VERIFIER BUILD FAILED & exit /b 1 )
bin\verify-shared-string-values.exe
if errorlevel 1 ( echo SHARED STRING VALUE SELFTEST FAILED & exit /b 1 )
bin\derecomp.exe u44-rawhash-selftest
if errorlevel 1 ( echo U44 RAW-HASH SELFTEST FAILED & exit /b 1 )
bin\derecomp.exe closure-index-selftest
if errorlevel 1 ( echo CLOSURE INDEX SELFTEST FAILED & exit /b 1 )
bin\derecomp.exe semantic-ir-selftest
if errorlevel 1 ( echo SEMANTIC IR SELFTEST FAILED & exit /b 1 )
bin\derecomp.exe semantic-ir-lowering-selftest
if errorlevel 1 ( echo SEMANTIC IR LOWERING SELFTEST FAILED & exit /b 1 )
bin\derecomp.exe semantic-ir-readable-selftest
if errorlevel 1 ( echo READABLE NAMING SELFTEST FAILED & exit /b 1 )
bin\derecomp.exe closure-map cert\cert_all.spawn.lua_B cert\closure-map-smoke.tsv
if errorlevel 1 ( echo CLOSURE MAP SMOKE TEST FAILED & exit /b 1 )
echo BUILD OK -^> bin\derecomp.exe
