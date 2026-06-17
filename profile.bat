@echo off
REM Using UTF-8 character encoding
chcp 65001 >nul 2>&1
::set PROMPT=$E[96m[%USERNAME%@%COMPUTERNAME%]$E[0m $E[95m$P$E[0m$E[90m❯$E[0m

REM START of profile, echo me
echo.
echo On %COMPUTERNAME%
set "ME=%USERDOMAIN%\%USERNAME%"
echo Logged on as %ME%

REM UNIX-style core utilities for Windows, see: https://learn.microsoft.com/en-us/windows/core-utils/overview
where ls >nul 2>&1
if %errorlevel% neq 0 (
  echo Using UNIX-style core utilities for Windows...
  winget install Microsoft.Coreutils
)

REM Local Environment Variables and Path of my tools/scripts
set EDITOR=vim
set MY_TOOLBOX=%HOME%\path\to\__REPOS__\tools.libs.scripts
if exist "%MY_TOOLBOX%" (
  set "PATH=%MY_TOOLBOX%\scripts;%MY_TOOLBOX%\tools;%PATH%"
)
if exist "C:\ProgramFiles\llvm\clang+llvm-20.1.4-x86_64-pc-windows-msvc\bin" (
  set "PATH=C:\ProgramFiles\llvm\clang+llvm-20.1.4-x86_64-pc-windows-msvc\bin;%PATH%"
)
if exist "C:\Program Files\Oracle\VirtualBox" (
  set "PATH=C:\Program Files\Oracle\VirtualBox;%PATH%"
)


REM Load MSVC environment
choice /t 3 /c yn /d y /m "Load MSVC environment"
if .%errorlevel%==.1 (
  if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat" -startdir=none -arch=x64 -host_arch=x64
  )
)

::Run PxProxy
if exist "C:\Program Files\px\px.exe" (
  where curl >nul 2>&1
  if not errorlevel 1 (
    echo. | curl -vf telnet://127.0.0.1:3128 2>&1
    if errorlevel 1 (
      start cmd.exe /k "C:\Program Files\px\px.exe"
    )
  )
)
set HTTP_PROXY=http://127.0.0.1:3128
set HTTPS_PROXY=http://127.0.0.1:3128


REM MACROs for command alias
doskey clear=cls

echo Profile loaded successfully.
