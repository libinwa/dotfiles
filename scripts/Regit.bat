@echo off && setlocal enabledelayedexpansion

TITLE Settings for using Vim portable...

:: Check administrator
REM >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
REM
REM if '%errorlevel%' NEQ '0' (
REM     goto UACPrompt
REM ) else (
REM     goto gotAdmin
REM )
REM
REM :UACPrompt
REM     echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
REM     echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
REM     "%temp%\getadmin.vbs"
REM     exit /B
REM
REM :gotAdmin
REM     if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
REM     pushd "%CD%"
REM     cd /d "%~dp0"

:begin
cls
color 0a
set PATH_ENV_BAK=%PATH%

:start
set PATH=%PATH_ENV_BAK%
set VIMHOME=%~dp0
::set VIMHOME=%VIMHOME:~0,-1%
set DATETIME=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
for /f "tokens=2 delims==" %%a in ('path') do (
    set "str=%%a"
    set str=!str: =+!
    for %%i in (!str!) do (
        set "var=%%i"
        set var=!var:+= !
        echo !var!>>change.txt
        for /f "delims=" %%i in ('findstr "Vim" change.txt') do set var=%%i
    )
)
del /q change.txt


echo #####################################################
echo # 1. Run Vim                                        #
echo # 2. Register context "Open with Vim"               #
echo # 3. Unregister context                             #
echo # 4. Query registration                             #
echo # 5. Quit (default)                                 #
echo #                                                   #
echo #####################################################
if NOT EXIST "vim.exe" (
  echo Vim binary isn't in this dir:  %VIMHOME%
  goto end
)
choice /t 10 /c 12345 /d 5 /m "Please select "
if .%errorlevel%==.1 goto startVim
if .%errorlevel%==.2 goto addRegedit
if .%errorlevel%==.3 goto delRegedit
if .%errorlevel%==.4 goto queryRegedit
if .%errorlevel%==.5 goto end

:end
exit


:addRegedit
REG ADD "HKCR\*\shell\gvim"
REG ADD "HKCR\*\shell\gvim" /ve /t REG_SZ /d "Open with Vim" /f
REG ADD "HKCR\*\shell\gvim" /v Icon /t REG_SZ /d "%VIMHOME%\bitmaps\vim.ico" /f
REG ADD "HKCR\*\shell\gvim\command"
REG ADD "HKCR\*\shell\gvim\command" /ve /t REG_SZ /d "\"%VIMHOME%\gvim.exe\" \"%%1\"" /f

REG ADD "HKCR\Directory\shell\gvim"
REG ADD "HKCR\Directory\shell\gvim" /ve /t REG_SZ /d "Open with Vim" /f
::REG ADD "HKCR\Directory\shell\gvim" /v Icon /t REG_SZ /d "%VIMHOME%\bitmaps\vim.ico" /f
REG ADD "HKCR\Directory\shell\gvim\command"
REG ADD "HKCR\Directory\shell\gvim\command" /ve /t REG_SZ /d "\"%VIMHOME%\gvim.exe\" \"%%V\"" /f

REG ADD "HKCR\Directory\Background\shell\gvim"
REG ADD "HKCR\Directory\Background\shell\gvim" /ve /t REG_SZ /d "Open with Vim" /f
REG ADD "HKCR\Directory\Background\shell\gvim" /v Icon /t REG_SZ /d "%VIMHOME%\bitmaps\vim.ico" /f
REG ADD "HKCR\Directory\Background\shell\gvim\command"
REG ADD "HKCR\Directory\Background\shell\gvim\command" /ve /t REG_SZ /d "\"%VIMHOME%\gvim.exe\" \"%%V\"" /f
goto start

:queryRegedit
REG QUERY "HKCR\*\shell\gvim" /ve
REG QUERY "HKCR\*\shell\gvim" /v Icon
REG QUERY "HKCR\*\shell\gvim\command" /ve

REG QUERY "HKCR\Directory\shell\gvim" /ve
REG QUERY "HKCR\Directory\shell\gvim" /v Icon
REG QUERY "HKCR\Directory\shell\gvim\command" /ve

REG QUERY "HKCR\Directory\Background\shell\gvim" /ve
REG QUERY "HKCR\Directory\Background\shell\gvim" /v Icon
REG QUERY "HKCR\Directory\Background\shell\gvim\command" /ve
goto start


:delRegedit
set /p answer= Delete Vim from reg (y/n)?
if .%answer%==.y (
    REG DELETE "HKCR\*\shell\gvim\command" /f
    REG DELETE "HKCR\*\shell\gvim" /f
    REG DELETE "HKCR\Directory\shell\gvim\command" /f
    REG DELETE "HKCR\Directory\shell\gvim" /f
    REG DELETE "HKCR\Directory\Background\shell\gvim\command" /f
    REG DELETE "HKCR\Directory\Background\shell\gvim" /f
    goto start
) else (
    goto start
)



:startVim
echo ########################################
echo env:PATH
SET PATH=%PATH%;%VIMHOME%
echo %PATH%
:: Register Vim without showing that message
"%VIMHOME%\gvim.exe" -silent -register
:: Run Vim so I can use it (then wait for it to close)
"%VIMHOME%\gvim.exe"
:: Now Vim has closed, unregister it
"%VIMHOME%\gvim.exe" -silent -unregister
goto start
