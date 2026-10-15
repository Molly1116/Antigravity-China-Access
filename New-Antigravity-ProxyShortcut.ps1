[CmdletBinding()]
param(
    [string]$ShortcutName = 'Antigravity (Proxy).lnk'
)

$ErrorActionPreference = 'Stop'

$projectRoot = $PSScriptRoot
$vbsPath = Join-Path $projectRoot 'Start-Antigravity-Proxy.vbs'
$antigravityExe = Join-Path $env:LOCALAPPDATA 'Programs\Antigravity\Antigravity.exe'
$desktop = [Environment]::GetFolderPath('Desktop')
$shortcutPath = Join-Path $desktop $ShortcutName

if (-not (Test-Path -LiteralPath $vbsPath -PathType Leaf)) {
    throw "Launcher not found: $vbsPath"
}

if (Test-Path -LiteralPath $shortcutPath) {
    throw "Shortcut already exists and was not overwritten: $shortcutPath"
}

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = Join-Path $env:WINDIR 'System32\wscript.exe'
$shortcut.Arguments = "//B //NoLogo `"$vbsPath`""
$shortcut.WorkingDirectory = $projectRoot
$shortcut.Description = 'Start Google Antigravity with a process-local HTTP proxy'

if (Test-Path -LiteralPath $antigravityExe -PathType Leaf) {
    $shortcut.IconLocation = "$antigravityExe,0"
}

$shortcut.Save()
Write-Output "Created: $shortcutPath"

