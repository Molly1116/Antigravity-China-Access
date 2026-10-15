[CmdletBinding()]
param(
    [string]$ProxyConfigPath = (Join-Path $PSScriptRoot 'proxy-config.psd1')
)

$ErrorActionPreference = 'Stop'

if (Test-Path -LiteralPath $ProxyConfigPath -PathType Leaf) {
    $proxyConfig = Import-PowerShellDataFile -LiteralPath $ProxyConfigPath
} else {
    $proxyConfig = @{
        ProxyUrl = 'http://127.0.0.1:10808'
        NoProxy = 'localhost,127.0.0.1,::1'
    }
}

$proxyUrl = [string]$proxyConfig.ProxyUrl
$noProxy = [string]$proxyConfig.NoProxy

if ([string]::IsNullOrWhiteSpace($proxyUrl)) {
    throw 'ProxyUrl is empty. Configure proxy-config.psd1 first.'
}

# Process scope only. These values are inherited by Antigravity and children
# started from it; nothing is written to User/System environment variables.
$env:HTTP_PROXY = $proxyUrl
$env:HTTPS_PROXY = $proxyUrl
$env:http_proxy = $proxyUrl
$env:https_proxy = $proxyUrl
$env:NO_PROXY = $noProxy
$env:no_proxy = $noProxy

$antigravityDir = Join-Path $env:LOCALAPPDATA 'Programs\Antigravity'
$antigravityExe = Join-Path $antigravityDir 'Antigravity.exe'
$officialShortcut = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Antigravity.lnk'

if (-not (Test-Path -LiteralPath $antigravityExe -PathType Leaf)) {
    throw "Antigravity executable not found: $antigravityExe"
}

# Prefer the vendor-created shortcut so the launch path matches normal use.
# Fall back to the official executable if the shortcut is absent.
if (Test-Path -LiteralPath $officialShortcut -PathType Leaf) {
    Start-Process -FilePath $officialShortcut -WorkingDirectory $antigravityDir
} else {
    Start-Process -FilePath $antigravityExe -WorkingDirectory $antigravityDir
}

