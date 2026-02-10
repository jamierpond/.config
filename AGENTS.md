# Platform Info

This dotfiles config targets:
- **ARM64 MacBook Pro** (Apple Silicon) - macOS with Homebrew
- **Ubuntu x86_64** - Linux with Nix

Package management uses **Nix** for cross-platform consistency. Scripts should handle both platforms and include appropriate PATH entries for Nix (`~/.nix-profile/bin`, `/nix/var/nix/profiles/default/bin`) and Homebrew (`/opt/homebrew/bin` for ARM Mac, `/usr/local/bin` for Intel).

