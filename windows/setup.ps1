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

# =============================================================================
# Install Scoop
# =============================================================================

Write-Info "Starting Windows bootstrap..."

if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Info "Scoop already installed"
} else {
    Write-Info "Installing Scoop..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

# Refresh PATH so scoop is available
$env:Path = "$env:USERPROFILE\scoop\shims;$env:Path"

# =============================================================================
# Clone dotfiles
# =============================================================================

if (-not $SkipClone) {
    # Need git to clone — scoop ships with git in main bucket
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Info "Installing git via scoop..."
        scoop install git
    }

    if (Test-Path "$DotfilesDir\.git") {
        Write-Info "Dotfiles already cloned at $DotfilesDir"
        Push-Location $DotfilesDir
        git pull 2>$null || (Write-Warn "Could not pull latest dotfiles")
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
    Write-Warn "No scoopfile.json found at $ScoopFile — skipping package install"
}

# =============================================================================
# Install extras not in scoop (winget / system packages)
# =============================================================================

# Neovim — winget has better builds
if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    Write-Info "Installing Neovim via winget..."
    winget install --id Neovim.Neovim --accept-source-agreements --accept-package-agreements
}

# Tailscale — system installer (not scoop, needs service)
if (-not (Get-Command tailscale -ErrorAction SilentlyContinue)) {
    Write-Info "Installing Tailscale via winget..."
    winget install --id tailscale.tailscale --accept-source-agreements --accept-package-agreements
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
        Write-Info "Symlinking Windows Terminal settings..."
        if (Test-Path $terminalTarget) {
            # Back up existing if it's not already a symlink
            $item = Get-Item $terminalTarget
            if ($item.LinkType -ne "SymbolicLink") {
                $backupPath = "$terminalTarget.bak"
                Move-Item $terminalTarget $backupPath -Force
                Write-Info "  Backed up existing settings to $backupPath"
            } else {
                Remove-Item $terminalTarget -Force
            }
        }
        New-Item -ItemType SymbolicLink -Path $terminalTarget -Target $TerminalSrc -Force | Out-Null
        Write-Info "  Linked: $terminalTarget -> $TerminalSrc"
    }
} else {
    Write-Warn "Windows Terminal not found — skipping settings symlink"
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
