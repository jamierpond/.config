#Requires -Version 5.1
<#
.SYNOPSIS
    Hands-off dotfiles sync. Registered as a scheduled task (logon + daily) by setup.ps1.

.DESCRIPTION
    1. Captures PowerToys Keyboard Manager edits made via the UI back into the repo
    2. Commits managed-config changes (scoped to windows/powertoys only)
    3. Pulls latest, pushes local commits
    4. Re-asserts the hard link if anything replaced the file
#>

$ErrorActionPreference = "Continue"

$DotfilesDir  = "$env:USERPROFILE\.config"
$KbdMgrSrc    = "$DotfilesDir\windows\powertoys\keyboard-manager.json"
$KbdMgrTarget = "$env:LOCALAPPDATA\Microsoft\PowerToys\Keyboard Manager\default.json"
$LogFile      = "$env:LOCALAPPDATA\dotfiles-sync.log"

function Log { param($Msg) "$(Get-Date -Format s) $Msg" | Add-Content $LogFile }

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    $env:Path = "$env:USERPROFILE\scoop\shims;$env:Path"
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Log "git not found, aborting"; exit 1 }

Set-Location $DotfilesDir
Log "sync start"

function Test-SameContent {
    param($A, $B)
    if (-not (Test-Path $A) -or (-not (Test-Path $B))) { return $false }
    (Get-FileHash $A).Hash -eq (Get-FileHash $B).Hash
}

# 1. Capture UI edits: if the link broke and the live file is newer, it wins
if ((Test-Path $KbdMgrTarget) -and -not (Test-SameContent $KbdMgrSrc $KbdMgrTarget)) {
    $live = Get-Item $KbdMgrTarget
    $repo = Get-Item $KbdMgrSrc -ErrorAction SilentlyContinue
    if (-not $repo -or $live.LastWriteTime -gt $repo.LastWriteTime) {
        Copy-Item $KbdMgrTarget $KbdMgrSrc -Force
        Log "captured PowerToys UI edits into repo"
    }
}

# 2. Commit managed-config changes only (never touches other working-tree edits)
git add windows/powertoys 2>&1 | Out-Null
if (git status --porcelain windows/powertoys) {
    git commit -m "sync: powertoys config from $env:COMPUTERNAME" 2>&1 | ForEach-Object { Log "  $_" }
}

# 3. Sync with remote
git pull --rebase --autostash 2>&1 | ForEach-Object { Log "  pull: $_" }
git push 2>&1 | ForEach-Object { Log "  push: $_" }

# 4. Re-assert the link (a pull or UI save can replace either file and detach it)
$targetItem = Get-Item $KbdMgrTarget -ErrorAction SilentlyContinue
if (-not $targetItem -or $targetItem.LinkType -ne "HardLink" -or -not (Test-SameContent $KbdMgrSrc $KbdMgrTarget)) {
    try {
        if ($targetItem) { Remove-Item $KbdMgrTarget -Force }
        New-Item -ItemType HardLink -Path $KbdMgrTarget -Target $KbdMgrSrc -Force | Out-Null
        Log "re-linked Keyboard Manager config"
    } catch {
        Log "re-link failed: $_"
    }
}

Log "sync done"
