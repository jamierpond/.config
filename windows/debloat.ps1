#Requires -Version 5.1
<#
.SYNOPSIS
    Rip out Windows 11 "engagement" cruft: Start-menu recommendations/fun-facts,
    lock-screen Spotlight tips, taskbar widgets (news/weather), search
    highlights, suggested content, and tips notifications.

.DESCRIPTION
    Everything here is per-user (HKCU) so NO ADMIN is required. Idempotent -
    safe to re-run. Called from setup.ps1; can also be run standalone:
      powershell -ExecutionPolicy Bypass -File ~/.config/windows/debloat.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Info { param($Msg) Write-Host "[INFO] $Msg" -ForegroundColor Green }

# Set a DWORD, creating the key path if it doesn't exist yet.
function Set-Reg {
    param([string]$Path, [string]$Name, [int]$Value)
    # Skip if already at the desired value (idempotent, and dodges values with
    # locked ACLs that are already correct - e.g. TaskbarDa).
    $cur = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name
    if ($null -ne $cur -and [int]$cur -eq $Value) { return }
    try {
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType DWord -Force | Out-Null
    } catch {
        # Fall back to reg.exe (succeeds on some values the .NET API rejects).
        $regPath = $Path -replace '^HKCU:', 'HKCU'
        reg add $regPath /v $Name /t REG_DWORD /d $Value /f *> $null
        if (-not $?) {
            Write-Host "[WARN] Could not set $Path\$Name : $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

Write-Info "Disabling Windows 'fun'/engagement features..."

# --- Start menu: kill the "recommendations" strip (tips, ads, fun facts on 24H2)
$start = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Start"
Set-Reg $start "Start_IrisRecommendations" 0   # tips/fun-facts/promoted apps row
Set-Reg $start "Start_TrackDocs"           0   # recommended recent files

# --- Content Delivery Manager: the mother lode of suggested/promoted content
$cdm = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
Set-Reg $cdm "SubscribedContentEnabled"        0
Set-Reg $cdm "SystemPaneSuggestionsEnabled"    0   # Start menu app suggestions
Set-Reg $cdm "SilentInstalledAppsEnabled"      0   # auto-installed promoted apps
Set-Reg $cdm "SoftLandingEnabled"              0   # "tips" popups
Set-Reg $cdm "RotatingLockScreenEnabled"       0   # Spotlight lock-screen rotation
Set-Reg $cdm "RotatingLockScreenOverlayEnabled" 0  # lock-screen "fun facts/tips"
Set-Reg $cdm "SubscribedContent-338387Enabled" 0   # lock screen facts/tips
Set-Reg $cdm "SubscribedContent-338388Enabled" 0   # Start menu suggestions
Set-Reg $cdm "SubscribedContent-338389Enabled" 0   # "get tips/tricks/suggestions"
Set-Reg $cdm "SubscribedContent-338393Enabled" 0   # Settings app suggested content
Set-Reg $cdm "SubscribedContent-353694Enabled" 0   # Settings app suggested content
Set-Reg $cdm "SubscribedContent-353696Enabled" 0   # Settings app suggested content
Set-Reg $cdm "SubscribedContent-353698Enabled" 0   # timeline/suggestions
Set-Reg $cdm "SubscribedContent-310093Enabled" 0   # Windows welcome/spotlight tour

# --- Search box "highlights" (the fun-facts/holidays doodles in search)
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" "IsDynamicSearchBoxEnabled" 0

# --- Taskbar widgets board (news & weather)
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" 0

# --- Advertising ID (personalised ads across apps)
Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" 0

# --- "Suggested content" / tips in the Settings app
$content = "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement"
Set-Reg $content "ScoopHeader" 0

Write-Info "  Restarting Explorer so changes take effect..."
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
# Explorer auto-restarts; nudge it in case it doesn't in this session.
Start-Process explorer.exe -ErrorAction SilentlyContinue

Write-Info "Done - Start menu, lock screen, search, and widgets de-cluttered."
