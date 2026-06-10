# Install orkai from OrkaiOS/installer (Windows).
# Usage (PowerShell):
#   irm https://raw.githubusercontent.com/OrkaiOS/installer/main/scripts/install.ps1 | iex
#   $env:ORKAI_VERSION = "v1.0.1"; irm ... | iex
#
# License: installing the binary does not grant a license. Activate after install:
#   orkai activate <KEY>   — keys from https://getorkai.com/pricing
$ErrorActionPreference = "Stop"

$Repo = if ($env:ORKAI_GITHUB_REPO) { $env:ORKAI_GITHUB_REPO } else { "OrkaiOS/installer" }
$Ref = if ($env:ORKAI_VERSION) { $env:ORKAI_VERSION } else { "main" }
$Asset = "orkai-windows-amd64.exe"

function Get-DownloadUrl {
    param([string]$AssetName)
    $releaseUrl = "https://github.com/$Repo/releases/download/$Ref/$AssetName"
    try {
        $head = Invoke-WebRequest -Uri $releaseUrl -Method Head -UseBasicParsing -ErrorAction Stop
        if ($head.StatusCode -eq 200) { return $releaseUrl }
    } catch {}
    return "https://raw.githubusercontent.com/$Repo/$Ref/$AssetName"
}

function Ensure-UserPath([string]$Dir) {
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$Dir*") {
        [Environment]::SetEnvironmentVariable("Path", "$userPath;$Dir", "User")
        $env:Path = "$env:Path;$Dir"
        Write-Host "Added $Dir to user PATH (restart terminal if orkai is not found)"
    }
}

$url = Get-DownloadUrl $Asset
$installRoot = if ($env:ORKAI_INSTALL_DIR) { $env:ORKAI_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA "Programs\orkai" }
$dest = Join-Path $installRoot "orkai.exe"

Write-Host "==> Installing orkai ($Ref) to $dest"
Write-Host "    Download: $url"

New-Item -ItemType Directory -Force -Path $installRoot | Out-Null
Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
Ensure-UserPath $installRoot

Write-Host "==> Installed: $(& $dest version)"

Write-Host @"

Next steps:
  1. Get a license (trial or paid): https://getorkai.com/pricing
  2. orkai activate <YOUR_KEY>
  3. orkai serve          # first-run setup, then use orkai start

Indexing, serve, and other write/compute commands require a valid license.
"@
