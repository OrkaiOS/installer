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
    $inRegistry = $userPath -and ($userPath -split ";" -contains $Dir)
    if (-not $inRegistry) {
        $newPath = if ($userPath) { "$userPath;$Dir" } else { $Dir }
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Host "Added $Dir to user PATH."
    }
    # Always sync the current session — VS Code / Windows Terminal
    # terminals inherit a stale env from their parent process, so even
    # if the registry already has the path, this session may not.
    $sessionPath = $env:Path -split ";"
    if ($sessionPath -notcontains $Dir) {
        $env:Path = "$env:Path;$Dir"
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

If 'orkai' is not recognized in THIS terminal, run:
  $env:Path = [Environment]::GetEnvironmentVariable('Path','User') + ';' + [Environment]::GetEnvironmentVariable('Path','Machine')
Or open a new terminal window.
"@
