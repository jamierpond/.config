# Native zsh prompt - 1:1 robbyrussell replica
setopt PROMPT_SUBST

# Load colors (sets up $fg, $fg_bold, $reset_color, etc.)
autoload -U colors && colors

# Git prompt info function
git_prompt_info() {
  local ref
  ref=$(git symbolic-ref --short HEAD 2>/dev/null) || return

  # Check if dirty
  if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    # Dirty: git:(branch) ✗
    echo "%{$fg_bold[blue]%}git:(%{$fg[red]%}${ref}%{$fg[blue]%}) %{$fg[yellow]%}✗%{$reset_color%} "
  else
    # Clean: git:(branch)
    echo "%{$fg_bold[blue]%}git:(%{$fg[red]%}${ref}%{$fg[blue]%})%{$reset_color%} "
  fi
}

# Exact robbyrussell format
PROMPT="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )%{$fg[cyan]%}%c%{$reset_color%} \$(git_prompt_info)"
