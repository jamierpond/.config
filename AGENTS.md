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

# Neovim Config Validation

After modifying any nvim config files, validate the config loads cleanly:

```bash
nvim --headless -c 'quit' 2>&1
```

If there are errors, they'll be printed to stderr. Fix them before considering the task done.

# Experiments Live In The Repo, Not `/tmp/`

Do NOT stash experimental scripts, scratch files, or WIP code in `/tmp/` (or `~/tmp`, `/var/tmp`, etc.). Put them in the working repo — preferably under an `./experiments/` directory, e.g. `./experiments/some-new-approach.py`. A dedicated dir keeps experiments grouped and easy to find/clean up, rather than scattered at the repo root.

Reasons:
- The human needs to be able to see and monitor what you're doing. Hidden files in `/tmp/` are invisible to the editor, file tree, and git status.
- WIP code is often useful content that may end up committed or referenced later. `/tmp/` gets wiped on reboot.
- The `.gitignore` allowlist pattern means unrelated scratch files won't accidentally get committed anyway — they'll be ignored until explicitly allowlisted.

If you genuinely need a throwaway file (e.g. piping a large blob to a temp location for a one-shot command), that's fine — but experiments, prototypes, and anything you might reference again belong in the repo.

# Gitignore — Allowlist Pattern

This repo uses an **allowlist** `.gitignore`: everything is ignored by default (`/*`), then specific files/dirs are included with `!` prefix (e.g. `!bin/`, `!tmux/`, `!nvim/`). If you create a new top-level config dir or file, you must add a `!dirname/` entry to `.gitignore` or it will be silently ignored.

