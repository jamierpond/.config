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
# Bash-specific: Prompt (robbyrussell style, matches zsh)
# =============================================================================
_set_prompt() {
  local branch git_info=""
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    local dirty=""
    [ -n "$(git status --porcelain 2>/dev/null)" ] && dirty=" \[\e[0;33m\]✗"
    git_info=" \[\e[1;34m\]git:(\[\e[0;31m\]${branch}\[\e[1;34m\])${dirty}\[\e[0m\]"
  fi
  PS1="\[\e[1;32m\]➜ \[\e[0;36m\]\W\[\e[0m\]${git_info} "
}
PROMPT_COMMAND=_set_prompt

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
