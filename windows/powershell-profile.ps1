# PowerShell profile - Windows. Dot-sourced by $PROFILE (stub written by
# windows/setup.ps1).
#
# Goal: make PowerShell feel like the bash/zsh shell in ~/.config (shellrc +
# zshrc + prompt.zsh + vi-mode.zsh). PowerShell is used here instead of Git
# Bash because MSYS process-spawn is ~1.5s per fork on this box; native PS
# spawns in ~50ms, so there's no startup or per-prompt lag.
#
# NOTE: this file must stay UTF-8 *with BOM* or Windows PowerShell 5.1 turns
# the ➜ / ✗ glyphs into mojibake. setup.ps1 / re-saves preserve the BOM.

# =============================================================================
# Environment
# =============================================================================
$env:EDITOR = if ($env:EDITOR) { $env:EDITOR } else { "nvim" }
if (Get-Command fd -ErrorAction SilentlyContinue) {
    $env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --exclude .git'
    $env:FZF_CTRL_T_COMMAND  = $env:FZF_DEFAULT_COMMAND
}
$env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border --no-mouse'

# =============================================================================
# Prompt - 1:1 robbyrussell replica (matches prompt.zsh)
#   ➜ <dir> git:(<branch>) ✗        arrow is red when the last command failed
# =============================================================================
function prompt {
    $ok = $?                       # capture BEFORE any git call clobbers it
    $e = [char]27
    $green = "$e[1;32m"; $red = "$e[0;31m"; $cyan = "$e[0;36m"
    $blue  = "$e[1;34m"; $yellow = "$e[0;33m"; $reset = "$e[0m"

    $arrow = if ($ok) { "$green" } else { "$red" }

    $cwd = Split-Path -Leaf $PWD.Path
    if ([string]::IsNullOrEmpty($cwd)) { $cwd = $PWD.Path }   # drive root

    $git = ""
    $branch = git symbolic-ref --short HEAD 2>$null
    if ($LASTEXITCODE -eq 0 -and $branch) {
        $dirty = if (git status --porcelain 2>$null) { " $yellow✗" } else { "" }
        $git = " ${blue}git:($red$branch$blue)$dirty$reset"
    }

    "$arrow➜ $cyan$cwd$reset$git "
}

# =============================================================================
# PSReadLine - vi mode + cursor shapes (matches vi-mode.zsh) + fzf-like history
# =============================================================================
Set-PSReadLineOption -EditMode Vi
try { Set-PSReadLineOption -ViModeIndicator Cursor } catch { }   # block/beam cursor per mode
try { Set-PSReadLineOption -HistorySearchCursorMovesToEnd } catch { }
# PredictionSource needs PSReadLine >= 2.1; this box has 2.0, so guard it.
try { Set-PSReadLineOption -PredictionSource History } catch { }

Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit
Set-PSReadLineKeyHandler -Key Tab     -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
# insert-mode readline muscle memory (ctrl-a/e/w/u)
Set-PSReadLineKeyHandler -Key Ctrl+a -Function BeginningOfLine
Set-PSReadLineKeyHandler -Key Ctrl+e -Function EndOfLine
Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardKillWord
Set-PSReadLineKeyHandler -Key Ctrl+u -Function BackwardDeleteLine

# =============================================================================
# fzf bindings - Ctrl+R history, Ctrl+T files, Alt+C cd (no PSFzf needed)
# =============================================================================
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    # Ctrl+R: fuzzy reverse history search
    Set-PSReadLineKeyHandler -Key Ctrl+r -ScriptBlock {
        $path = (Get-PSReadLineOption).HistorySavePath
        if (-not (Test-Path $path)) { return }
        $line = $null; $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        $sel = Get-Content $path | Where-Object { $_ -notmatch '^\s*$' } |
               Select-Object -Unique | fzf --tac --no-sort --query "$line"
        if ($sel) {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($sel)
        }
    }
    # Ctrl+T: insert a fuzzy-picked file path
    Set-PSReadLineKeyHandler -Key Ctrl+t -ScriptBlock {
        $sel = fzf
        if ($sel) { [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$sel") }
    }
    # Alt+C: fuzzy cd into a subdirectory
    Set-PSReadLineKeyHandler -Key Alt+c -ScriptBlock {
        $walker = if (Get-Command fd -ErrorAction SilentlyContinue) { 'fd --type d --hidden --exclude .git' } else { $null }
        $dir = if ($walker) { Invoke-Expression $walker | fzf } else { fzf --walker=dir }
        if ($dir) {
            Set-Location $dir
            [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
        }
    }
}

# =============================================================================
# zoxide - fast dir jumping (`z <term>`, `zi` for interactive fzf pick)
# Replaces the fzf dir-jump aliases (jd/c) from shellrc.
# =============================================================================
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# =============================================================================
# Unix-isms + modern CLI tools (eza / bat / rg / fd all installed)
# =============================================================================
Set-Alias which Get-Command
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function so { . $PROFILE }              # reload profile (matches bashrc `so`)
function mkcd { param($d) New-Item -ItemType Directory -Force $d | Out-Null; Set-Location $d }

if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls { eza --group-directories-first --icons @args }
    function ll { eza -l  --group-directories-first --icons --git @args }
    function la { eza -la --group-directories-first --icons --git @args }
    function lt { eza --tree --level=2 --icons @args }
} else {
    function ll { Get-ChildItem -Force @args }
    function la { Get-ChildItem -Force @args }
}

# =============================================================================
# git - oh-my-zsh git-plugin aliases (the ones muscle memory relies on).
# gp / gd are intentionally NOT redefined: shellrc repurposes them
# (gcloud-project-switch / git-diff-filter) on the real shells.
# =============================================================================
function gst  { git status @args }
function gss  { git status -s @args }
function ga   { git add @args }
function gaa  { git add --all @args }
function gcmsg { git commit -m @args }
function gcam { git commit -a -m @args }
function gco  { git checkout @args }
function gcb  { git checkout -b @args }
function gb   { git branch @args }
function gf   { git fetch @args }
function gl   { git pull @args }
function gpush { git push @args }
function glog { git log --oneline --decorate --graph @args }
function gundo { git reset --soft HEAD~1 @args }
function grape { git grep @args }
function cf   { git --no-pager diff --name-only @args }
function gitbump { git commit -m 'chore: bump ci, empty commit' --allow-empty }
Set-Alias bump gitbump
function smu  { git submodule update --init @args }
function smur { git submodule update --init --recursive @args }
function wtl  { git worktree list @args }
function wtp  { git worktree prune @args }
function lg   { lazygit @args }

# =============================================================================
# python / venv (Windows venv layout: Scripts\Activate.ps1)
# =============================================================================
function va  { . .\venv\Scripts\Activate.ps1 }
function nv  { python -m venv venv }
function nva { nv; va }
function uva { uv venv venv; va }

# =============================================================================
# tmux -> psmux on Windows (shellrc aliases: t / ta / tks / tso).
# psmux is the Windows tmux port; it reads ~/.psmux.conf (stub -> windows/psmux.conf).
# =============================================================================
if (Get-Command psmux -ErrorAction SilentlyContinue) {
    function t   { psmux @args }
    function ta  { psmux attach @args }
    function tks { psmux kill-server @args }
    function tso { psmux source-file ~/.psmux.conf @args }
    Set-Alias tmux psmux
}

# =============================================================================
# misc
# =============================================================================
Set-Alias g gemini
function m { make @args }
