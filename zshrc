# zshrc - zsh-specific config
# Sources shellrc for portable stuff, then adds zsh-only features

this_dir=$(dirname "$0")

# =============================================================================
# Source portable config (shared with bash)
# =============================================================================
source "$this_dir/shellrc"

# =============================================================================
# Zsh-specific: Nix/home-manager integration
# =============================================================================
if [[ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]]; then
  source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
fi

# =============================================================================
# Zsh-specific: Modules (prompt, vi-mode, completion)
# =============================================================================
source "$this_dir/prompt.zsh"
source "$this_dir/vi-mode.zsh"
source "$this_dir/completion.zsh"

# =============================================================================
# Zsh-specific: History
# =============================================================================
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt APPEND_HISTORY
unsetopt SHARE_HISTORY

# =============================================================================
# Zsh-specific: macOS SDK (cached for speed)
# =============================================================================
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

# =============================================================================
# Zsh-specific: Aliases
# =============================================================================
alias so="source ~/.zshrc"
alias a="yapi"

# =============================================================================
# Zsh-specific: fzf
# =============================================================================
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# =============================================================================
# Zsh-specific: Yapi
# =============================================================================
YAPI_ZSH="$HOME/projects/yapi/bin/yapi.zsh"
[ -f "$YAPI_ZSH" ] && source "$YAPI_ZSH"

# Yapi completion - lazy loaded
yapi() { unfunction yapi; source <(command yapi completion zsh) 2>/dev/null; command yapi "$@"; }

# =============================================================================
# Zsh-specific: Pyenv (lazy load)
# =============================================================================
pyenv() {
  unfunction pyenv
  eval "$(command pyenv init -)"
  pyenv "$@"
}

# =============================================================================
# Zsh-specific: Google Cloud SDK
# =============================================================================
if [ -f '/Users/jamiepond/Downloads/google-cloud-sdk/path.zsh.inc' ]; then
  source '/Users/jamiepond/Downloads/google-cloud-sdk/path.zsh.inc'
fi
if [ -f '/Users/jamiepond/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then
  source '/Users/jamiepond/Downloads/google-cloud-sdk/completion.zsh.inc'
fi

# =============================================================================
# Zsh-specific: Nix helpers
# =============================================================================
_nix_system() {
  if [[ "$(uname)" == "Darwin" ]]; then
    [[ "$(uname -m)" == "arm64" ]] && echo "aarch64-darwin" || echo "x86_64-darwin"
  else
    echo "x86_64-linux"
  fi
}

nsp() {
  local query="$1"
  if [[ -z "$query" ]]; then
    echo "Usage: nsp <search-term>"
    return 1
  fi
  nix search nixpkgs "$query" 2>/dev/null | less
}

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

nix-edit() {
  ${EDITOR:-nvim} ~/.config/home/default.nix && nrs
}

# =============================================================================
# Zsh-specific: Helper for command history
# =============================================================================
execute_command() {
  local cmd="$1"
  print -s "$cmd" 2>/dev/null || history -s "$cmd" 2>/dev/null
  eval "$cmd"
}
