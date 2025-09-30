#
# START of profile, echo $Me
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
# Useful alias
Function Func-Fda { fd -IH }
Set-Alias -Name fda -Value Func-Fda
Function Func-Rga { rg -uuu }
Set-Alias -Name rga -Value Func-Rga
Function Get-HelpDetailed { Get-Help $args[0] -Detailed }
Set-Alias -Name man -Value Get-HelpDetailed
Set-Alias -Name vi -Value vim

