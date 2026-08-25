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
echo BUILD OK -^> bin\derecomp.exe
