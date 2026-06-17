@echo off

echo Choose your session:
echo 1. Quick (1 min)
echo 2. Deep (5 min)
choice /t 5 /c 12 /d 1 /m "Please select "
if .%errorlevel%==.1 (
  call :session 6 6 8 3
  goto end
)
if .%errorlevel%==.2 (
  call :session 6 6 8 15
  goto end
)
goto end

:session
rem start new session
rem usage:
rem session ^<inhale time^> ^<hold time^> ^<exhale time^> ^<cycles^>
set /a cycles=%4
set /a sum=%1+%2+%3
for /l %%i in (1,1,%cycles%) do (
    echo Processing cycle %%i/%cycles%
    call :count 5 2
    for /l %%j in (0,5,%sum%) do  echo | set /p dummp=%%j/%sum%...
    echo.
    echo | set /p dummp=inhale
    call :count %1 1
    echo | set /p dummp=hold
    call :count %2 1
    echo | set /p dummp=exhale
    call :count %3 1
    echo 100%%
)
echo Take it easy.
exit /b

:count
rem start counting
rem usage:
rem count  ^<countdown^> ^<interval^>
set /a countdown=%1
:procloop
::time period (<interval> in seconds)
timeout /t %2 /nobreak >nul
::windows-batch-echo-without-new-line
echo | set /p dummy=###
set /a countdown-=1
if %countdown% gtr 0 goto procloop
::echo | set /p dummy=done.
set /a sum=%1 * %2
echo  time elapsed %sum%s
exit /b


:end
echo Bye!
exit /b
