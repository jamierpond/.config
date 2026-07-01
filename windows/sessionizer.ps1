#Requires -Version 5.1
<#
    Native PowerShell psmux sessionizer - Windows port of bin/scripts/tmux-sessionizer.
    Bound in windows/psmux.conf (prefix+f / prefix+F) and launched directly by psmux
    (no Git Bash). The bash version paid a login-shell startup + MSYS `find` fork
    storm on every press, which is multi-second on this ARM64 box.

    Usage:
      sessionizer.ps1              # fzf-pick a project dir
      sessionizer.ps1 <dir>        # jump straight to <dir>
#>
param([string]$Target)

$ErrorActionPreference = 'Stop'

$searchDirs = @(
    $HOME
    "$HOME\projects"
    "$HOME\projects\mayk-it"
    "$HOME\projects\TamberWorkspace"
) | Where-Object { Test-Path -LiteralPath $_ }

if ($Target) {
    $selected = $Target
} else {
    $candidates = foreach ($d in $searchDirs) {
        Get-ChildItem -LiteralPath $d -Directory -ErrorAction SilentlyContinue |
            ForEach-Object { $_.FullName }
    }
    $selected = $candidates | fzf
}

if ([string]::IsNullOrWhiteSpace($selected)) { exit 0 }
$selected = $selected.Trim()

# Session name: leaf dir, with dots/spaces -> underscores (tmux dislikes both)
$name = (Split-Path -Leaf $selected) -replace '[.\s]', '_'

# Are we already inside psmux? (switch instead of attach). Check every var psmux
# might set - bound to prefix+f we're always inside, and guessing wrong sends us
# down the blocking `attach` path.
$inside = [bool]($env:TMUX -or $env:PSMUX -or $env:PSMUX_SESSION -or $env:PSMUX_ACTIVE)

# psmux refuses a nested new-session unless these are cleared (psmux 3.3.x)
Remove-Item Env:PSMUX_SESSION -ErrorAction SilentlyContinue
Remove-Item Env:PSMUX_ACTIVE  -ErrorAction SilentlyContinue

# Is a server already up?
psmux ls *> $null
$hasServer = ($LASTEXITCODE -eq 0)

# Fresh start: no server and not inside -> create attached and done
if (-not $inside -and -not $hasServer) {
    psmux new-session -s $name -c $selected
    exit 0
}

# Create the session if it doesn't exist yet (exact-match name)
psmux has-session -t "=$name" 2> $null
if ($LASTEXITCODE -ne 0) {
    psmux new-session -d -s $name -c $selected
}

if ($inside) {
    psmux switch-client -t $name
} else {
    psmux attach -t $name
}
