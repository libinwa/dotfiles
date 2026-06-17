#
#
# 拷贝到 $PROFILE 以加载 Profile
#
# 或者 编辑 $PROFILE 添加如下代码使用点号 . 进行 Dot-Sourcing 加载
# $targetProfile = "\path\to\Microsoft.PowerShell_profile.ps1"
# if (Test-Path -Path $targetProfile) {
#   . "$targetProfile"
# }
#
#

#
# START of profile, echo me
Write-Host "In Customizations for [$($Host.Name)]"
Write-Host "On $(hostname)"
$ME = whoami
Write-Host "Logged on as $ME"

#
# Generic configurations
$FormatEnumerationLimit = 99
$PSDefaultParameterValues = @{
    '*:autosize'       = $true
    'Receive-Job:keep' = $true
    '*:Wrap'           = $true
}

#
# Local Environment Variables and Path of my tools/scripts
$env:EDITOR = "vim"
$myToolbox= "$env:HOME\path\to\__REPOS__\tools.libs.scripts"
if (Test-Path -Path $myToolbox) {
  $env:PATH = "$myToolbox\scripts;$myToolbox\tools;" + $env:PATH
}

$targetDir = "C:\\ProgramFiles\\llvm\\clang+llvm-20.1.4-x86_64-pc-windows-msvc\\bin"
if (Test-Path -Path $targetDir) {
  $env:PATH = "$targetDir;" + $env:PATH
}

if (Test-Path -Path "C:\\Program Files\\Oracle\\VirtualBox") {
  $env:PATH = "C:\\Program Files\\Oracle\\VirtualBox;" + $env:PATH
}


#
# Load MSVC environment
#$targetDir = "C:\Program Files\Microsoft Visual Studio\2022\Community"
#if (Test-Path -Path $targetDir) {
#  Import-Module "$targetDir\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
#  Enter-VsDevShell -VsInstallPath "$targetDir" -SkipAutomaticLocation -DevCmdArguments "-arch=x64 -host_arch=x64"
#}

#
# Run PxProxy
Write-Host "Setting HTTP(S)_PROXY environment to use local PX proxy listing on http://127.0.0.1:3128"
$env:https_proxy = "http://127.0.0.1:3128"
$env:http_proxy = "http://127.0.0.1:3128"
Get-ChildItem env:http* -ErrorAction Ignore
Get-ChildItem env:no_proxy -ErrorAction Ignore
# Check whether some process is answering on the PX port
$pxAccessible=(Test-NetConnection -ComputerName 127.0.0.1 -Port 3128).TcpTestSucceeded
Write-Host "TCP port 3128 answering=$pxAccessible"
if (!$pxAccessible)
{
  Write-Host "Starting PX with path C:\Program Files\PX\PX.EXE and arguments -ArgumentList "--foreground=1", "--log=4""
  Start-Process -FilePath "C:\Program Files\PX\PX.EXE" -WindowStyle 2 -ArgumentList "--foreground=1", "--log=4"
  Start-Sleep -Seconds 2
}
else
{
  Write-Host -ForegroundColor green "PX is already running"
}


#
# Navigating file system quickly with fzf and fd
if ((Get-Command fzf*) -and (Get-InstalledModule -Name PSFzf)) {
    if (Get-Command fd*) {
        $env:FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git --max-depth 6"
        $env:FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        $env:FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git --max-depth 5"
    }

    # Offical fzf didn't provide initial script for pwsh (provided for bash)
    # PSFzf is pwsh module that wraps fzf
    # https://github.com/kelleyma49/PSFzf
    Import-Module PSFzf
    Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
    Set-PsFzfOption -TabExpansion
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

#
# Useful Command Alias
Function Func-Fda { fd -IH }
Set-Alias -Name fda -Value Func-Fda
Function Func-Rga { rg -uuu }
Set-Alias -Name rga -Value Func-Rga
Function Get-HelpDetailed { Get-Help $args[0] -Detailed }
Set-Alias -Name man -Value Get-HelpDetailed
Set-Alias -Name vi -Value vim

Write-Host "Profile loaded successfully."
