# Platform Info

This dotfiles config targets:
- **ARM64 MacBook Pro** (Apple Silicon) - macOS with Homebrew
- **Ubuntu x86_64** - Linux with Nix

Package management uses **Nix** for cross-platform consistency. Scripts should handle both platforms and include appropriate PATH entries for Nix (`~/.nix-profile/bin`, `/nix/var/nix/profiles/default/bin`) and Homebrew (`/opt/homebrew/bin` for ARM Mac, `/usr/local/bin` for Intel).

# Package Installation

**NEVER use `npm install -g` or `pip install` directly** - these will fail because the Nix store is read-only.

For packages managed by Nix (defined in `flake.nix` or `home/default.nix`):
- Update the flake inputs: `nix flake update`
- Rebuild: `darwin-rebuild switch --flake ~/.config` (macOS) or `home-manager switch --flake ~/.config` (Linux)

For packages not yet in nixpkgs or when you need a newer version than nixpkgs has:
- Install to local prefix: `npm install -g <pkg>@<version> --prefix ~/.local`
- This works because `~/.local/bin` is in PATH and takes precedence

# Gitignore — Allowlist Pattern

This repo uses an **allowlist** `.gitignore`: everything is ignored by default (`/*`), then specific files/dirs are included with `!` prefix (e.g. `!bin/`, `!tmux/`, `!nvim/`). If you create a new top-level config dir or file, you must add a `!dirname/` entry to `.gitignore` or it will be silently ignored.

