# zshrc
this_dir=$(dirname "$0")

# Secrets (not version controlled)
if [[ -f ~/.secrets ]]; then
  source ~/.secrets
else
  echo "WARNING: ~/.secrets not found - env vars may be missing"
fi

# Nix profile (home-manager packages)
if [[ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]]; then
  source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
fi
export PATH="$HOME/.nix-profile/bin:$PATH"

# Modular configs
source "$this_dir/prompt.zsh"
source "$this_dir/vi-mode.zsh"
source "$this_dir/completion.zsh"

# PATH setup - scripts directory first
export PATH="$this_dir/bin/scripts:$PATH"
export PATH="$PATH:/usr/local/go/bin"
# Go bin path (static - faster than go env)
export PATH="$PATH:$HOME/go/bin"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/snap/bin"
export PATH="$PATH:$HOME/.cargo/bin"

# Environment variables
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000
export SCREENRC="$HOME/.config/screenrc"
export HOMEBREW_NO_AUTO_UPDATE=1
export XDG_CONFIG_HOME="$HOME/.config"
export VIRTUAL_ENV="venv"
export UV_PROJECT_ENVIRONMENT="venv"
export VCPKG_ROOT="$HOME/vcpkg"
export DO_NOT_TRACK=1
export MANPATH="$HOME/.local/share/man:$MANPATH"
# macOS SDK for cgo/framework headers (CoreAudio, etc.)
# Cached to avoid slow xcrun on every shell
if [[ "$(uname)" == "Darwin" ]]; then
  _sdkroot_cache="$HOME/.cache/sdkroot"
  if [[ -f "$_sdkroot_cache" ]]; then
    export SDKROOT=$(<"$_sdkroot_cache")
  else
    mkdir -p ~/.cache
    export SDKROOT=$(xcrun --show-sdk-path)
    echo "$SDKROOT" > "$_sdkroot_cache"
  fi
  unset _sdkroot_cache
fi

# History options
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt APPEND_HISTORY
unsetopt SHARE_HISTORY

# Helper function for command history
function execute_command() {
  local cmd="$1"
  print -s "$cmd" 2>/dev/null || history -s "$cmd" 2>/dev/null
  eval "$cmd"
}

# Yapi
YAPI_ZSH="$HOME/projects/yapi/bin/yapi.zsh"
[ -f "$YAPI_ZSH" ] && source "$YAPI_ZSH"
alias a="yapi"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Aliases - scripts (short names for long script names)
alias spicy="claude --dangerously-skip-permissions"
alias r="temp-script-edit-run"
alias mf="makefile-target-fzf"
alias dt="jest-describe-test-fzf"
alias re="list-recent-files"
alias pport="port-show-process"
alias sz="disk-usage-summary"
alias jd="git-directory-jump-fzf"
alias jv="json-validate-pretty"
alias c="directory-navigate-fzf"
alias tsh="pytorch-tensor-shape"
alias dsh="docker-image-shell"
alias gp="gcloud-project-switch"
alias gssh="gcloud-instance-ssh"
alias gstart="gcloud-instance-start"
alias gstop="gcloud-instance-stop"
alias gscp="gcloud-instance-scp"
alias co="git-branch-checkout-fzf"
alias e="git-shell-script-run-fzf"
alias cl="github-repo-clone-fzf"
alias tget="tar-extract-file-fzf"
alias tcat="tar-cat-file-fzf"
alias gls="git-files-fzf"
alias pt="pytest-test-fzf"
alias bell="bell-sound"
alias yt="youtube-download"
alias ytv="youtube-download -v"
alias da="docker-container-attach-fzf"
alias dcp="docker-container-cp-fzf"
alias png="crush-png"
alias gif="crush-gif"
alias jpeg="crush-jpeg"
alias mpng="crush-move-png"
alias mgif="crush-move-gif"
alias mjpeg="crush-move-jpeg"

# Aliases - docker
alias dockernuke='docker kill $(docker ps -q)'
alias dn='dockernuke'

# Aliases - system
alias archbtw='~/.config/bin/scripts/arch.sh'
alias imgp="bash ~/.config/bin/scripts/clipimage.sh"
alias npf="bash ~/.config/bin/scripts/npmf"
alias prf="~/.config/bin/scripts/get-all-pr-feedback"
alias so="source ~/.zshrc"

# Aliases - python/venv
alias pipi="pip install -r requirements.txt"
alias nv="python3 -m venv venv"
alias va="source venv/bin/activate"
alias nva="nv && va"
alias uva="uv venv venv && va"

# Aliases - tar
alias tarls="tar -tvf"
alias tls="tar -tvf"
alias untar="tar -xvf"

# Aliases - git
alias smu="git submodule update --init"
alias smur="git submodule update --init --recursive"
alias gtree="git ls-files | tree --fromfile"
alias cf="git --no-pager diff --name-only"
alias grape="git grep"

# Aliases - GPU
alias gpu="watch -n 0.5 nvidia-smi"
alias pgpu="nvidia-smi --query-compute-apps=pid --format=csv,noheader"
alias fgpu="sudo fuser -v /dev/nvidia*"
alias kgpu="fgpu | grep . | tr ' ' '\n' | xargs kill -9"
alias rgpu="pkill wandb && pgpu | xargs -I {} kill -9 {} && kgpu"

# Aliases - SSH/remote
alias lm="sh ~/projects/lambda-machine/remote.sh"
alias mm="ssh -tt jamie@mm.pond.audio"
alias vie="sh ~/projects/lambda-machine/vienna-remote.sh"
alias ms="ssh administrator@208.52.154.141"
alias ssh-win="TERM=xterm ssh"

# Aliases - tmux
alias ta="tmux attach"
alias t="tmux"
alias tmux='tmux -f ~/.config/tmux/tmux.conf'
alias tks="tmux kill-server"

# Phone-friendly tmux helpers (short commands, numbered lists)
# Same dirs as tmux-sessionizer but no fzf — just numbers
_tmux_project_dirs() {
  find $HOME/projects $HOME/projects/mayk-it /tmp/time "$HOME/Music/NME/Project Files" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | xargs ls -dtu 2>/dev/null | tail -r
}
tmls() {
  local sessions dirs
  sessions=$(tmux list-sessions -F '#{session_name} (#{session_windows}w) #{?session_attached,*,}' 2>/dev/null)
  dirs=$(_tmux_project_dirs)
  if [ -n "$sessions" ]; then
    echo "== sessions =="
    echo "$sessions" | nl -v0 -ba -w2 -s'  '
    local offset=$(echo "$sessions" | wc -l | tr -d ' ')
    echo ""
    echo "== projects (id starts at $offset) =="
    echo "$dirs" | nl -v"$offset" -ba -w2 -s'  '
  else
    echo "== no active sessions =="
    echo ""
    echo "== projects =="
    echo "$dirs" | nl -v0 -ba -w2 -s'  '
  fi
}
tmas() {
  [ -z "$1" ] && { tmls; return 1; }
  local id=$1
  local sessions dirs num_sessions
  sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)
  num_sessions=$(echo "$sessions" | grep -c . 2>/dev/null || echo 0)
  # If id falls within active sessions, just attach
  if [ "$id" -lt "$num_sessions" ] 2>/dev/null; then
    local target=$(echo "$sessions" | sed -n "$((id+1))p")
    tmux attach -t "$target" 2>/dev/null || tmux switch-client -t "$target"
    return
  fi
  # Otherwise it's a project dir — create session if needed
  dirs=$(_tmux_project_dirs)
  local dir_index=$((id - num_sessions))
  local selected=$(echo "$dirs" | sed -n "$((dir_index+1))p")
  [ -z "$selected" ] && { echo "bad id"; tmls; return 1; }
  local selected_name=$(basename "$selected" | tr . _)
  if ! tmux has-session -t="$selected_name" 2>/dev/null; then
    tmux new-session -ds "$selected_name" -c "$selected"
  fi
  tmux attach -t "$selected_name" 2>/dev/null || tmux switch-client -t "$selected_name"
}
tmks() {
  [ -z "$1" ] && { tmls; return 1; }
  local target
  local sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)
  target=$(echo "$sessions" | sed -n "$((${1}+1))p")
  [ -z "$target" ] && { echo "bad id (only active sessions can be killed)"; tmls; return 1; }
  tmux kill-session -t "$target"
  echo "killed $target"
}

# Aliases - misc tools
alias ka="killall"
alias kaf="killall -9"
alias dec2hex="printf '%x\n'"
alias d2h="printf '%x\n'"
alias f="ranger"
alias fcp="~/.config/bin/scripts/ffplay-local.sh"
alias fpl="~/.config/bin/scripts/ffplay-local.sh"
alias img="~/.config/bin/scripts/img-preview.sh"
alias dls="lsblk"
alias ddd="rm -rf ~/Library/Developer/Xcode/DerivedData"
alias ksmo='~/.config/bin/scripts/ksmo'
alias cpp-compile="~/.config/bin/scripts/cpp-compile"
alias cppc="~/.config/bin/scripts/cpp-compile"
alias o="crush"
alias qb="/Applications/qutebrowser.app/Contents/MacOS/qutebrowser"
alias ra="osascript ~/.config/bin/scripts/refresh-ableton.scpt"
alias refresh-ableton="osascript ~/.config/bin/scripts/refresh-ableton.scpt"
alias bwon="shortcuts run \"bw-on\""
alias bwoff="shortcuts run \"bw-off\""
alias m="make"
alias g="gemini"
alias rp="~/.config/bin/scripts/repo-print"
alias r2-sync="~/.config/r2-backup/r2-sync"
alias r2-browse="~/.config/r2-backup/r2-browse"
alias gde="~/.config/bin/scripts/git-diff-exclude"
alias gd="~/.config/bin/scripts/git-diff-filter"
alias mrd="list-recent-files ~/Downloads -n 1"

# gcloud projects list
function gpls() {
  gcloud projects list
}

# Auto-activate venv if found
git_root=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -n "$git_root" ]; then
  if [ -d "$git_root/venv" ]; then
    echo "Found venv at $git_root/venv"
    source "$git_root/venv/bin/activate"
  elif [ -d "$git_root/.venv" ]; then
    echo "Found venv at $git_root/.venv"
    source "$git_root/.venv/bin/activate"
  fi
fi

# Pyenv - lazy load
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
pyenv() {
  unfunction pyenv
  eval "$(command pyenv init -)"
  pyenv "$@"
}

# Google Cloud SDK
if [ -f '/Users/jamiepond/Downloads/google-cloud-sdk/path.zsh.inc' ]; then
  source '/Users/jamiepond/Downloads/google-cloud-sdk/path.zsh.inc'
fi
if [ -f '/Users/jamiepond/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then
  source '/Users/jamiepond/Downloads/google-cloud-sdk/completion.zsh.inc'
fi

# Yapi completion - lazy loaded on first use
_yapi_completion_loaded=0
_load_yapi_completion() {
  if (( _yapi_completion_loaded == 0 )) && command -v yapi &>/dev/null; then
    source <(yapi completion zsh)
    _yapi_completion_loaded=1
  fi
}
yapi() { _load_yapi_completion; command yapi "$@"; }

# =============================================================================
# Nix helpers - making nix ergonomic
# =============================================================================

# Detect current nix system
_nix_system() {
  if [[ "$(uname)" == "Darwin" ]]; then
    [[ "$(uname -m)" == "arm64" ]] && echo "aarch64-darwin" || echo "x86_64-darwin"
  else
    echo "x86_64-linux"
  fi
}

# Search nixpkgs with fzf
nsp() {
  local query="$1"
  if [[ -z "$query" ]]; then
    echo "Usage: nsp <search-term>"
    return 1
  fi
  nix search nixpkgs "$query" 2>/dev/null | less
}

# Dev shell picker (fzf) - works on both Darwin and Linux
ds() {
  local flake="${1:-$HOME/.config}"
  local sys=$(_nix_system)
  local shells=$(nix flake show "$flake" --json 2>/dev/null | jq -r ".devShells[\"$sys\"] // {} | keys[]")
  if [[ -z "$shells" ]]; then
    echo "No devShells found in $flake for $sys"
    return 1
  fi
  local shell=$(echo "$shells" | fzf --prompt="dev shell> " --height=40%)
  [[ -n "$shell" ]] && nix develop "$flake#$shell" --command zsh
}

# Quick edit packages and rebuild
nix-edit() {
  ${EDITOR:-nvim} ~/.config/home/default.nix && nrs
}
