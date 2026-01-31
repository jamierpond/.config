# Native zsh completion configuration

# Initialize completion system
autoload -Uz compinit
compinit -d ~/.cache/zcompdump

# Case-insensitive matching
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# Menu selection
zstyle ':completion:*' menu select

# Colored completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Group matches by category
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# Cache completions for faster loading
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh-completions

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

# Process completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
