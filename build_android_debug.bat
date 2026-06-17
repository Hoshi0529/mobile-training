@echo off
setlocal

set "ROOT=%~dp0."
set "DRIVE="

for %%D in (M N O P Q) do (
  if not exist %%D:\nul (
    set "DRIVE=%%D:"
    goto found_drive
  )
)

echo No free temporary drive letter found.
exit /b 1

:found_drive
subst %DRIVE% "%ROOT%"
if errorlevel 1 exit /b 1

pushd %DRIVE%\
call flutter build apk --debug
set "EXIT_CODE=%ERRORLEVEL%"
popd

subst %DRIVE% /D
exit /b %EXIT_CODE%
