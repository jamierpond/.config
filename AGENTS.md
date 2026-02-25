# Platform Info

This dotfiles config targets:
- **ARM64 MacBook Pro** (Apple Silicon) - macOS with Homebrew
- **Ubuntu x86_64** - Linux with Nix

Package management uses **Nix** for cross-platform consistency. Scripts should handle both platforms and include appropriate PATH entries for Nix (`~/.nix-profile/bin`, `/nix/var/nix/profiles/default/bin`) and Homebrew (`/opt/homebrew/bin` for ARM Mac, `/usr/local/bin` for Intel).

# Gitignore — Allowlist Pattern

This repo uses an **allowlist** `.gitignore`: everything is ignored by default (`/*`), then specific files/dirs are included with `!` prefix (e.g. `!bin/`, `!tmux/`, `!nvim/`). If you create a new top-level config dir or file, you must add a `!dirname/` entry to `.gitignore` or it will be silently ignored.

