# Native zsh vi-mode configuration

# Enable vi mode
bindkey -v

# Reduce key timeout for faster mode switching
export KEYTIMEOUT=1

# Cursor shape changes
# Uses ANSI escape sequences for cursor shape:
# \e[6 q - steady bar (insert mode)
# \e[2 q - steady block (normal mode)
# \e[4 q - steady underline

function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[2 q'  # block cursor for normal mode
  elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ $1 = 'beam' ]]; then
    echo -ne '\e[6 q'  # bar cursor for insert mode
  fi
}
zle -N zle-keymap-select

# Set bar cursor on startup and for each new prompt
function zle-line-init {
  echo -ne '\e[6 q'
}
zle -N zle-line-init

# Ensure bar cursor when entering insert mode
function vi-cmd-mode {
  echo -ne '\e[2 q'
  zle .vi-cmd-mode
}
zle -N vi-cmd-mode

# Standard vi keybindings additions
bindkey -M viins '^?' backward-delete-char  # backspace
bindkey -M viins '^H' backward-delete-char  # ctrl-h
bindkey -M viins '^W' backward-kill-word    # ctrl-w
bindkey -M viins '^U' backward-kill-line    # ctrl-u
bindkey -M viins '^A' beginning-of-line     # ctrl-a
bindkey -M viins '^E' end-of-line           # ctrl-e

# History search in normal mode
bindkey -M vicmd '/' history-incremental-search-backward
bindkey -M vicmd '?' history-incremental-search-forward
bindkey -M vicmd 'k' up-line-or-history
bindkey -M vicmd 'j' down-line-or-history

# Allow ctrl-r for reverse history search in insert mode
bindkey -M viins '^R' history-incremental-search-backward
