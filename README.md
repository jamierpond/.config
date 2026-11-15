# dotfiles

Cross-platform dotfiles for macOS (ARM) and Linux (x86_64). Nix for packages, zsh for shell.

## Install

```bash
# Linux (hands macOS over to mac-bootstrap.sh)
curl -fsSL https://raw.githubusercontent.com/jamierpond/.config/main/setup.sh | bash
# macOS
curl -fsSL https://raw.githubusercontent.com/jamierpond/.config/main/mac-bootstrap.sh | bash
# Windows (PowerShell)
irm https://raw.githubusercontent.com/jamierpond/.config/main/windows/setup.ps1 | iex
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
