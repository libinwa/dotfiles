@echo off
setlocal enabledelayedexpansion
if '%1'=='' goto SHOW_USAGE
echo.
echo Check MSVC environment...
where cl >nul 2>nul && where cmake >nul 2>nul
if !errorlevel! neq 0 (
  echo Prepare MSVC environment...
  pushd %~dp0
  cd /d C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Auxiliary\\Build
  if NOT EXIST "vcvarsall.bat" (
    @echo Cannot find "vcvarsall.bat", please check vs2022 compile environment.
    popd
    exit /b 1
  )
  call vcvarsall.bat x86_amd64
  popd
)

echo.
echo The following environment are used:
echo   -- CWD: !cd!
echo   -- MSVC:
where cl && cl
echo.


echo.
echo Running: %0 %*
echo.

:: change dir if optional path param was given
if exist "%~1\." (
  set "PROJECT_DIR=%~df1"
  pushd %~dp0
  cd /d "!PROJECT_DIR!"
  ::::::get rest params by shift::::::
  :loop_shift
  if "%~1"=="" goto endloop_shift
  if not defined params (
    set "params=%~1"
    rem skip this param
    set "params= "
  ) else (
    set "params=!params! %~1"
  )
  shift
  goto loop_shift
  :endloop_shift
  if NOT "!params!"=="" (
    call :run_cmake !params!
  ) else (
    echo ERROR: params are not enough.
  )
  popd
  goto :end
) else (
  call :run_cmake %*
  goto :end
)


:run_cmake
if "%1"=="--ctest" (
  ::::::get rest params by shift::::::
  :loop_shft
  if "%~1"=="" goto endloop_shft
  if not defined args (
    set "args=%~1"
    rem skip this param
    set "args= "
  ) else (
    set "args=!args! %~1"
  )
  shift
  goto loop_shft
  :endloop_shft
  if NOT "!args!"=="" (
    call :dotest !args!
    exit /b
  ) else (
    echo ERROR: no enough params to do ctest.
    exit /b
  )
) else (
  call :domake %*
  exit /b
)


::::::::::::::::::::::::::do make:::::::::::::::::::::::::::
:domake
rem Make Project
echo.
echo CMake Version:
where cmake && cmake --version
if !errorlevel! neq 0 (
  echo CMake version invalid, errorlevel=!errorlevel!.
  exit /b -1
)

echo.
echo CMake Command:
echo cmake %*
echo =======================================================
cmake %*
if NOT errorlevel 0 (
  echo CMake failed, errorlevel=!errorlevel!.
  exit /b -1
)
exit /b


::::::::::::::::::::::::::do test:::::::::::::::::::::::::::
:dotest
rem Test Project
echo.
echo CMake Version:
where cmake && cmake --version && ctest --version
if !errorlevel! neq 0 (
  echo CMake version invalid, errorlevel=!errorlevel!.
  exit /b -1
)

echo.
echo CTest Command:
echo ctest %*
echo =======================================================
ctest %*
if NOT errorlevel 0 (
  echo CTest failed, errorlevel=!errorlevel!.
  exit /b -1
)
exit /b


::::::::::::::::::::::::::show information:::::::::::::::::::::::::::
:SHOW_USAGE
echo This script is to run cmake...
echo.
echo usage:
echo   %0 [^<project-dir>] ^<cmake-option^> [^<cmake-option^>]...
echo.
echo Processing info is logged to stdout.
goto :end

:end
echo.
echo DONE.
endlocal
