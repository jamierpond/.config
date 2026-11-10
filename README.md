# dotfiles

Cross-platform dotfiles for macOS (ARM) and Linux (x86_64). Nix for packages, zsh for shell.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/jamierpond/.config/main/setup.sh | bash
# or
just setup
```

## Layout

```
~/.config/
├── zshrc, prompt.zsh, vi-mode.zsh   # Shell
├── bin/scripts/                      # Utility scripts + short aliases
├── nvim/                             # Neovim (lazy.nvim)
├── tmux/                             # Tmux (prefix: C-a)
├── flake.nix, home/, darwin/         # Nix
└── justfile                          # just switch / update / gc
```

## Git policy

Whitelist `.gitignore` — everything ignored by default, explicitly track what you want.
