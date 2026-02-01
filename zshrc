# Modernized zshrc - no oh-my-zsh
this_dir=$(dirname "$0")

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
command -v go &>/dev/null && export PATH="$PATH:$(go env GOPATH)/bin"
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
alias bso="source ~/.bashrc"

# Aliases - python/venv
alias pipi="pip install -r requirements.txt"
alias new-venv="python3 -m venv venv"
alias nv="python3 -m venv venv"
alias cv="python3 -m venv venv"
alias act-venv="source venv/bin/activate"
alias va="source venv/bin/activate"
alias nva="nv && va"
alias uva="uv venv venv && va"
alias pos="poetry shell"

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
alias mm="ssh jamie@mm.pond.audio"
alias vie="sh ~/projects/lambda-machine/vienna-remote.sh"
alias ms="ssh administrator@208.52.154.141"

# Aliases - tmux
alias ta="tmux attach"
alias t="tmux"
alias tmux='tmux -f ~/.config/tmux/tmux.conf'
alias tks="tmux kill-server"

# Aliases - misc tools
alias ka="killall"
alias kaf="killall -9"
alias ll="ls -alF"
alias la="ls -A"
alias ls='ls -a --color=auto'
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
alias oc="crush"
alias o="oc"
alias qb="/Applications/qutebrowser.app/Contents/MacOS/qutebrowser"
alias ra="osascript ~/.config/bin/scripts/refresh-ableton.scpt"
alias refresh-ableton="osascript ~/.config/bin/scripts/refresh-ableton.scpt"
alias bwon="shortcuts run \"bw-on\""
alias bwoff="shortcuts run \"bw-off\""
alias mkae="make"
alias mk="make"
alias ma="make"
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
set +e
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

# Lazy load nvm (saves ~1s startup)
export NVM_DIR="$HOME/.config/nvm"
nvm() {
  unfunction nvm node npm npx 2>/dev/null
  source "$NVM_DIR/nvm.sh"
  nvm "$@"
}
node() {
  unfunction nvm node npm npx 2>/dev/null
  source "$NVM_DIR/nvm.sh"
  nvm use default --silent
  node "$@"
}
npm() {
  unfunction nvm node npm npx 2>/dev/null
  source "$NVM_DIR/nvm.sh"
  nvm use default --silent
  npm "$@"
}
npx() {
  unfunction nvm node npm npx 2>/dev/null
  source "$NVM_DIR/nvm.sh"
  nvm use default --silent
  npx "$@"
}

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

# Yapi completion
if command -v yapi &> /dev/null; then
  source <(yapi completion zsh)
fi
