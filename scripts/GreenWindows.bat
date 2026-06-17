@echo off
set WNDCOLO_DEFAULT="255 255 255"
set WNDCOLO_GREEN="202 234 206"
set WNDCOLO2_DEFAULT="0xffffff"
set WNDCOLO2_GREEN="0xcaeace"
set /p answer= Switch Green Window Colo (y/n)?
if .%answer%==.y (
reg add "HKCU\Control Panel\Colors" /v Window /t REG_SZ /d %WNDCOLO_GREEN% /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\DefaultColors\Standard" /v Window /t REG_DWORD /d %WNDCOLO2_GREEN% /f
) else (
reg add "HKCU\Control Panel\Colors" /v Window /t REG_SZ /d %WNDCOLO_DEFAULT% /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\DefaultColors\Standard" /v Window /t REG_DWORD /d %WNDCOLO2_DEFAULT% /f
)
reg query "HKCU\Control Panel\Colors" /v Window
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\DefaultColors\Standard" /v Window
pause