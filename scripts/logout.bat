@echo off
rem start processing of logout

echo | set /p dummy=Windows is going to logout
::counting down 30 times
set /a countdown=30

:procloop
::time period 1 seconds
timeout /t 1 /nobreak >nul
::windows-batch-echo-without-new-line
echo | set /p dummy=.
set /a countdown-=1
if %countdown% gtr 0 goto procloop

echo | set /p dummy=done.
call rundll32.exe user32.dll,LockWorkStation
exit /b

