#Requires -Version 5.1
<#
.SYNOPSIS
    Bootstrap a fresh Windows machine to a fully working dev environment.

.DESCRIPTION
    Run from a fresh Windows install:
      irm https://raw.githubusercontent.com/jamierpond/.config/main/windows/setup.ps1 | iex

    Or locally:
      powershell -ExecutionPolicy Bypass -File ~/.config/windows/setup.ps1
#>
param(
    [switch]$SkipClone,
    [switch]$SkipSSHD,
    [switch]$ServerMode
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# =============================================================================
# Config
# =============================================================================

$DotfilesRepo = "https://github.com/jamierpond/.config.git"
$DotfilesDir  = "$env:USERPROFILE\.config"
$ProjectsDir  = "$env:USERPROFILE\projects"
$ScoopFile    = "$DotfilesDir\windows\scoopfile.json"
$GitConfigSrc = "$DotfilesDir\windows\gitconfig"
$TerminalSrc  = "$DotfilesDir\windows\terminal-settings.json"
$KbdMgrSrc    = "$DotfilesDir\windows\powertoys\keyboard-manager.json"

$Repos = @(
    @{ Name = "yapi"; Url = "https://github.com/jamierpond/yapi.git" }
)

# =============================================================================
# Helpers
# =============================================================================

function Write-Info  { param($Msg) Write-Host "[INFO] $Msg" -ForegroundColor Green }
function Write-Warn  { param($Msg) Write-Host "[WARN] $Msg" -ForegroundColor Yellow }
function Write-Err   { param($Msg) Write-Host "[ERROR] $Msg" -ForegroundColor Red; exit 1 }

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Try to symlink Src -> Target; fall back to a plain copy when symlinks need
# privileges we don't have (non-admin without Developer Mode). Backs up any
# pre-existing real file to .bak once.
function Install-ConfigLink {
    param([string]$Target, [string]$Src, [string]$Label)

    if (-not (Test-Path $Src)) { return }

    if (Test-Path $Target) {
        $item = Get-Item $Target -Force
        if ($item.LinkType -eq "SymbolicLink") {
            Remove-Item $Target -Force
        } elseif (-not (Test-Path "$Target.bak")) {
            Move-Item $Target "$Target.bak" -Force
            Write-Info "  Backed up existing $Label to $Target.bak"
        } else {
            Remove-Item $Target -Force
        }
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Target -Target $Src -Force -ErrorAction Stop | Out-Null
        Write-Info "  Linked $Label -> $Src"
    } catch {
        Copy-Item $Src $Target -Force
        Write-Warn "  Symlink needs admin/Developer Mode; copied $Label instead (edits won't sync live)"
    }
}

# =============================================================================
# Install Scoop
# =============================================================================

Write-Info "Starting Windows bootstrap..."

if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Info "Scoop already installed"
} else {
    Write-Info "Installing Scoop..."
    # May be overridden by a higher-scope policy (e.g. already Bypass); non-fatal.
    try { Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop } catch { Write-Warn "Could not set execution policy (likely already permissive): $($_.Exception.Message)" }
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

# Refresh PATH so scoop is available
$env:Path = "$env:USERPROFILE\scoop\shims;$env:Path"

# =============================================================================
# Clone dotfiles
# =============================================================================

if (-not $SkipClone) {
    # Need git to clone - scoop ships with git in main bucket
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Info "Installing git via scoop..."
        scoop install git
    }

    if (Test-Path "$DotfilesDir\.git") {
        Write-Info "Dotfiles already cloned at $DotfilesDir"
        Push-Location $DotfilesDir
        git pull 2>$null; if (-not $?) { Write-Warn "Could not pull latest dotfiles" }
        Pop-Location
    } else {
        Write-Info "Cloning dotfiles..."
        if (Test-Path $DotfilesDir) {
            # Init in existing dir (preserve existing files like scoop config)
            Push-Location $DotfilesDir
            git init
            git remote add origin $DotfilesRepo
            git fetch origin main
            git reset origin/main
            git checkout -- .
            git branch -M main
            git branch --set-upstream-to=origin/main main
            Pop-Location
        } else {
            git clone $DotfilesRepo $DotfilesDir
        }
    }
}

# =============================================================================
# Install packages via Scoop
# =============================================================================

if (Test-Path $ScoopFile) {
    Write-Info "Installing packages from scoopfile.json..."

    $scoopConfig = Get-Content $ScoopFile -Raw | ConvertFrom-Json

    # Add buckets
    $existingBuckets = scoop bucket list 2>$null | ForEach-Object { $_.Name }
    foreach ($bucket in $scoopConfig.buckets) {
        if ($existingBuckets -notcontains $bucket.Name) {
            Write-Info "  Adding bucket: $($bucket.Name)"
            scoop bucket add $bucket.Name $bucket.Source
        }
    }

    # Install apps (skip already installed)
    $installedApps = (scoop list 2>$null).Name
    foreach ($app in $scoopConfig.apps) {
        if ($installedApps -contains $app.Name) {
            Write-Info "  $($app.Name) already installed"
        } else {
            Write-Info "  Installing $($app.Name)..."
            scoop install $app.Name
        }
    }
} else {
    Write-Warn "No scoopfile.json found at $ScoopFile - skipping package install"
}

# =============================================================================
# Install extras not in scoop (winget / system packages)
# =============================================================================

# Neovim - winget has better builds
if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    Write-Info "Installing Neovim via winget..."
    winget install --id Neovim.Neovim --accept-source-agreements --accept-package-agreements
}

# Tailscale - system installer (not scoop, needs service)
if (-not (Get-Command tailscale -ErrorAction SilentlyContinue)) {
    Write-Info "Installing Tailscale via winget..."
    winget install --id tailscale.tailscale --accept-source-agreements --accept-package-agreements
}

# 1Password desktop app - GUI installer (like Tailscale), so winget not scoop.
# It's what enables the CLI's biometric integration (Windows Hello unlock, the
# recommended `op` sign-in below) plus browser autofill. No CLI shim to probe,
# so check winget's list with an exact (-e) id match on the desktop app (its id,
# AgileBits.1Password, is distinct from the CLI's AgileBits.1Password.CLI).
$op1pInstalled = winget list --id AgileBits.1Password -e --accept-source-agreements 2>$null | Select-String -SimpleMatch "AgileBits.1Password"
if (-not $op1pInstalled) {
    Write-Info "Installing 1Password desktop app via winget..."
    winget install --id AgileBits.1Password --accept-source-agreements --accept-package-agreements
} else {
    Write-Info "1Password desktop app already installed"
}

# =============================================================================
# 1Password CLI sign-in
# =============================================================================
#
# `op` (installed via scoop, above) is REQUIRED to build the native Tamber app:
# apps/native/CMakeLists.txt runs `op run` at cmake-configure time to materialize
# the op/<env>.env secrets into apps/vite/.env.local. Installing the binary is
# automated; signing in is not (it's interactive and tied to the account), so we
# verify auth and print the exact steps if it's not ready yet.

if (Get-Command op -ErrorAction SilentlyContinue) {
    # `op account list` is non-interactive and exits non-zero when no account is
    # configured / signed in. Swallow output; we only care about success.
    op account list *> $null
    if ($?) {
        Write-Info "1Password CLI signed in"
    } else {
        Write-Warn "1Password CLI (op) is installed but not signed in."
        Write-Warn "  It's required to build the native app (secrets export at cmake time)."
        Write-Warn "  Recommended: 1Password app > Settings > Developer >"
        Write-Warn "    'Integrate with 1Password CLI' (Touch ID / Windows Hello unlock)."
        Write-Warn "  Or sign in manually:  op signin"
        Write-Warn "  You need access to the Tamber-dev (and Tamber-prod) vaults."
    }
} else {
    Write-Warn "1Password CLI (op) not found on PATH after install - open a new shell and re-run, or 'scoop install 1password-cli'."
}

# =============================================================================
# Git config
# =============================================================================

Write-Info "Configuring git..."

# Point global gitconfig to include our managed config
$gitconfigPath = "$env:USERPROFILE\.gitconfig"
$includeLine = "[include]`n`tpath = ~/.config/windows/gitconfig"

if (Test-Path $gitconfigPath) {
    $content = Get-Content $gitconfigPath -Raw
    if ($content -notmatch "windows/gitconfig") {
        Write-Info "  Adding include directive to .gitconfig"
        # Prepend include so our config is the base, user overrides come after
        $includeLine + "`n" + $content | Set-Content $gitconfigPath -NoNewline
    }
} else {
    $includeLine | Set-Content $gitconfigPath -NoNewline
}

# =============================================================================
# Windows Terminal settings (symlink)
# =============================================================================

$terminalDir = Get-ChildItem "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_*" -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
if ($terminalDir) {
    $terminalTarget = Join-Path $terminalDir.FullName "LocalState\settings.json"
    if (Test-Path $TerminalSrc) {
        Write-Info "Installing Windows Terminal settings..."
        Install-ConfigLink -Target $terminalTarget -Src $TerminalSrc -Label "Windows Terminal settings"
    }
} else {
    Write-Warn "Windows Terminal not found - skipping settings symlink"
}

# =============================================================================
# PowerToys Keyboard Manager settings (symlink)
# =============================================================================

$kbdMgrDir = "$env:LOCALAPPDATA\Microsoft\PowerToys\Keyboard Manager"
if (Test-Path $kbdMgrDir) {
    $kbdMgrTarget = Join-Path $kbdMgrDir "default.json"
    if (Test-Path $KbdMgrSrc) {
        Write-Info "Installing PowerToys Keyboard Manager settings..."
        Install-ConfigLink -Target $kbdMgrTarget -Src $KbdMgrSrc -Label "Keyboard Manager settings"
    }
} else {
    Write-Warn "PowerToys not found - skipping Keyboard Manager symlink"
}

# =============================================================================
# psmux config (source-file stub - survives file replacement, no admin needed)
# =============================================================================

$psmuxTarget = "$env:USERPROFILE\.psmux.conf"
"source-file ~/.config/windows/psmux.conf" | Set-Content $psmuxTarget -NoNewline
Write-Info "psmux config stub written: $psmuxTarget sources windows/psmux.conf"

# =============================================================================
# PowerShell profile (dot-source stub - survives file replacement, no admin needed)
# =============================================================================

$psProfileDir = Split-Path $PROFILE
New-Item -ItemType Directory -Path $psProfileDir -Force | Out-Null
". `"$DotfilesDir\windows\powershell-profile.ps1`"" | Set-Content $PROFILE
Write-Info "PowerShell profile stub written: $PROFILE sources windows/powershell-profile.ps1"

# =============================================================================
# Git Bash profile (source stub - survives file replacement, no admin needed)
# Written LF-only, no BOM: bash fails on CRLF/BOM in rc files.
# =============================================================================

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$bashrc        = "# Load dotfiles bash config (stub written by ~/.config/windows/setup.ps1)`n[ -f ~/.config/bashrc ] && source ~/.config/bashrc`n"
$bashProfile   = "# Login shells: load ~/.bashrc (stub written by ~/.config/windows/setup.ps1)`n[ -f ~/.bashrc ] && source ~/.bashrc`n"
[System.IO.File]::WriteAllText("$env:USERPROFILE\.bashrc", ($bashrc -replace "`r",''), $utf8NoBom)
[System.IO.File]::WriteAllText("$env:USERPROFILE\.bash_profile", ($bashProfile -replace "`r",''), $utf8NoBom)
Write-Info "Git Bash stubs written: ~/.bashrc + ~/.bash_profile source ~/.config/bashrc"

# =============================================================================
# Alacritty config (import stub - survives file replacement, no admin needed)
# =============================================================================

$alacrittyDir = "$env:APPDATA\alacritty"
New-Item -ItemType Directory -Path $alacrittyDir -Force | Out-Null
$alacrittySrc = "$DotfilesDir\windows\alacritty.toml" -replace '\\', '/'
"[general]`nimport = [`"$alacrittySrc`"]" | Set-Content "$alacrittyDir\alacritty.toml"
Write-Info "Alacritty config stub written: imports windows/alacritty.toml"

# =============================================================================
# Dotfiles auto-sync (scheduled task: logon + daily)
# =============================================================================

Write-Info "Registering dotfiles auto-sync..."
$syncScript = "$DotfilesDir\windows\sync.ps1"
$syncCmd = "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$syncScript`""

# Daily at noon via schtasks (works without admin, unlike Register-ScheduledTask in some sessions)
schtasks /create /tn "DotfilesSync" /tr $syncCmd /sc daily /st 12:00 /f | Out-Null

# At logon via HKCU Run key (no admin needed)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "DotfilesSync" -Value $syncCmd
Write-Info "  DotfilesSync runs at logon and daily at noon"

# =============================================================================
# Debloat: disable Windows 'fun'/engagement features (per-user, no admin)
# =============================================================================

$debloatScript = "$DotfilesDir\windows\debloat.ps1"
if (Test-Path $debloatScript) {
    Write-Info "Running debloat (Start menu/lock screen/widgets/search cleanup)..."
    & $debloatScript
} else {
    Write-Warn "debloat.ps1 not found at $debloatScript - skipping"
}

# =============================================================================
# Clone project repos
# =============================================================================

Write-Info "Setting up project repos..."
New-Item -ItemType Directory -Path $ProjectsDir -Force | Out-Null

foreach ($repo in $Repos) {
    $target = Join-Path $ProjectsDir $repo.Name
    if (Test-Path $target) {
        Write-Info "  $($repo.Name) already exists"
    } else {
        Write-Info "  Cloning $($repo.Name)..."
        git clone $repo.Url $target
    }
}

# =============================================================================
# SSH server (requires admin)
# =============================================================================

if (-not $SkipSSHD) {
    $sshdService = Get-Service sshd -ErrorAction SilentlyContinue
    if ($sshdService) {
        if ($sshdService.StartType -ne "Automatic" -or $sshdService.Status -ne "Running") {
            if (Test-Admin) {
                Write-Info "Configuring sshd for Tailscale..."
                Set-Service -Name sshd -StartupType Automatic
                Start-Service sshd
                Write-Info "  sshd is running and set to start on boot"
            } else {
                Write-Warn "sshd needs admin to configure. Run this in an elevated shell:"
                Write-Warn "  Set-Service -Name sshd -StartupType Automatic; Start-Service sshd"
            }
        } else {
            Write-Info "sshd already running with Automatic start"
        }

        # Set Git Bash as default shell for SSH sessions
        $currentShell = Get-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -ErrorAction SilentlyContinue
        $gitBash = "C:\Program Files\Git\bin\bash.exe"
        if ($currentShell.DefaultShell -ne $gitBash) {
            if (Test-Admin) {
                Write-Info "Setting Git Bash as default SSH shell..."
                New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value $gitBash -PropertyType String -Force | Out-Null
                Write-Info "  SSH default shell set to Git Bash"
            } else {
                Write-Warn "Setting SSH default shell needs admin. Run in an elevated shell:"
                Write-Warn "  New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value '$gitBash' -PropertyType String -Force"
            }
        } else {
            Write-Info "SSH default shell already set to Git Bash"
        }
    } else {
        Write-Warn "OpenSSH Server not installed. Install via:"
        Write-Warn "  Settings > Apps > Optional Features > OpenSSH Server"
    }
}

# =============================================================================
# Server mode: never sleep, lid close does nothing
# =============================================================================

if ($ServerMode) {
    Write-Info "Configuring server power settings (never sleep, lid close = do nothing)..."
    powercfg /change standby-timeout-ac 0
    powercfg /change standby-timeout-dc 0
    powercfg /change hibernate-timeout-ac 0
    powercfg /change hibernate-timeout-dc 0
    powercfg /change monitor-timeout-ac 0
    powercfg /change monitor-timeout-dc 0
    powercfg /setacvalueindex scheme_current sub_buttons lidaction 0
    powercfg /setdcvalueindex scheme_current sub_buttons lidaction 0
    powercfg /setactive scheme_current
    Write-Info "  Sleep, hibernate, and monitor timeout disabled"
    Write-Info "  Lid close action set to do nothing"
}

# =============================================================================
# Done
# =============================================================================

Write-Host ""
Write-Info "=========================================="
Write-Info " Windows bootstrap complete!"
Write-Info "=========================================="
Write-Host ""
Write-Host "What's set up:"
Write-Host "  - Scoop packages: ~/.config/windows/scoopfile.json"
Write-Host "  - Git config:     ~/.config/windows/gitconfig (included via ~/.gitconfig)"
Write-Host "  - Neovim config:  ~/.config/nvim/ (auto-detected by nvim)"
Write-Host "  - Lazygit config: ~/.config/lazygit/ (auto-detected)"
Write-Host "  - Terminal:       symlinked from ~/.config/windows/terminal-settings.json"
Write-Host "  - Keyboard Mgr:   symlinked from ~/.config/windows/powertoys/keyboard-manager.json"
Write-Host "  - 1Password:      desktop app + CLI (op) - needed for native app builds"
Write-Host "  - Auto-sync:      DotfilesSync task pulls/pushes configs at logon + daily"
Write-Host "  - psmux (tmux):   config linked from ~/.config/windows/psmux.conf"
Write-Host "  - sshd:           running, auto-start on boot"
if ($ServerMode) {
    Write-Host "  - Power:          never sleep, lid close does nothing (server mode)"
}
Write-Host "  - Projects:       ~/projects/"
Write-Host ""
Write-Host "To update packages later:"
Write-Host "  scoop update *"
Write-Host "  scoop export > ~/.config/windows/scoopfile.json"
Write-Host ""
