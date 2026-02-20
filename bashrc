# bashrc - bash-specific config
# Sources shellrc for portable stuff, then adds bash-only features

# Get script directory
BASHRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =============================================================================
# Source portable config (shared with zsh)
# =============================================================================
source "$BASHRC_DIR/shellrc"

# =============================================================================
# Bash-specific: History
# =============================================================================
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=10000
export HISTFILESIZE=10000
shopt -s histappend

# =============================================================================
# Bash-specific: Aliases
# =============================================================================
alias so="source ~/.bashrc"

# =============================================================================
# Bash-specific: Prompt (simple version of robbyrussell)
# =============================================================================
_git_branch() {
  git symbolic-ref --short HEAD 2>/dev/null
}

_git_dirty() {
  [ -n "$(git status --porcelain 2>/dev/null)" ] && echo " ✗"
}

PS1='\[\e[1;32m\]➜ \[\e[0;36m\]\W\[\e[0m\] \[\e[1;34m\]$(_git_branch && echo "git:(\[\e[0;31m\]$(_git_branch)\[\e[1;34m\])")\[\e[0;33m\]$(_git_dirty)\[\e[0m\] '

# =============================================================================
# Bash-specific: fzf
# =============================================================================
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# =============================================================================
# Bash-specific: Pyenv (lazy load)
# =============================================================================
pyenv() {
  unset -f pyenv
  eval "$(command pyenv init -)"
  pyenv "$@"
}
