# Jamie's Dotfiles

Cross-platform dotfiles for macOS and Linux, optimized for fast startup and productivity.

## Quick Start

```bash
# One-liner install
curl -fsSL https://raw.githubusercontent.com/jamierpond/.config/main/setup.sh | bash

# Or with Nix
make bootstrap   # Full setup
make switch      # Apply changes
```

## Architecture

```
~/.config/
├── zshrc, prompt.zsh, vi-mode.zsh, completion.zsh   # Shell config
├── bin/scripts/                                      # 80+ utility scripts
├── nvim/                                             # Neovim (lazy.nvim)
├── tmux/                                             # Tmux config
├── ranger/                                           # File manager
├── flake.nix, home/, darwin/                         # Nix infrastructure
└── Makefile                                          # Build automation
```

## Shell (Zsh)

Native zsh setup (no oh-my-zsh) with **~0.3s startup** (down from ~11s).

### Modular Config
- `prompt.zsh` - robbyrussell-style prompt with git status
- `vi-mode.zsh` - vi keybindings with cursor shape changes
- `completion.zsh` - native zsh completion (case-insensitive, colored)

### Performance
- **Lazy loading**: nvm, pyenv only initialize when first used
- **Auto venv**: activates `venv/` or `.venv/` at git root

## Remote Mac Access (`mac` command)

Run commands and open files on your Mac from Linux via cloudflared tunnel.

```bash
# Run any command
mac "open https://example.com"
mac "say 'hello from linux'"

# Open files (auto-detects type)
mac song.mp3           # → ffplay
mac image.png          # → Preview.app
mac document.pdf       # → open

# Custom handler
mac -c "open -a VLC {}" video.mp4
mac -c "afplay {}" notification.wav
```

### Features
- **SHA-based caching**: files only copy once
- **Extension detection**: audio/video → ffplay, images → Preview, etc.
- **Cloudflared tunnel**: works anywhere with internet

### Related Commands
- `bell` - play notification sound on Mac (works from Linux)
- `img` - preview image on Mac
- `fpl` - play audio/video on Mac

## Scripts (`bin/scripts/`)

80+ utility scripts with short aliases. Pattern: descriptive script names, 2-3 char aliases.

### FZF-Powered Selection
| Alias | Script | Description |
|-------|--------|-------------|
| `mf` | `makefile-target-fzf` | Select & run Makefile target |
| `dt` | `jest-describe-test-fzf` | Run Jest test by description |
| `pt` | `pytest-test-fzf` | Run pytest test |
| `co` | `git-branch-checkout-fzf` | Checkout git branch |
| `c` | `directory-navigate-fzf` | Navigate directories |
| `jd` | `git-directory-jump-fzf` | Jump to git repos |
| `da` | `docker-container-attach-fzf` | Attach to container |
| `dsh` | `docker-image-shell` | Shell into Docker image |
| `cl` | `github-repo-clone-fzf` | Clone GitHub repo |

### Git Tools
| Alias | Script | Description |
|-------|--------|-------------|
| `gd` | `git-diff-filter` | Filtered diff (skip lines, exclude patterns) |
| `gde` | `git-diff-exclude` | Diff with file exclusions |
| `gls` | `git-files-fzf` | Select git-tracked files |
| `cf` | - | Show changed file names only |

### Google Cloud
| Alias | Script | Description |
|-------|--------|-------------|
| `gp` | `gcloud-project-switch` | Switch GCP project |
| `gssh` | `gcloud-instance-ssh` | SSH to instance |
| `gscp` | `gcloud-instance-scp` | SCP to/from instance |
| `gstart` | `gcloud-instance-start` | Start instance |
| `gstop` | `gcloud-instance-stop` | Stop instance |

### Media & Images
| Alias | Script | Description |
|-------|--------|-------------|
| `yt` | `youtube-download` | Download YouTube audio |
| `ytv` | `youtube-download -v` | Download YouTube video |
| `png` | `crush-png` | Compress PNG |
| `gif` | `crush-gif` | Compress GIF |
| `jpeg` | `crush-jpeg` | Compress JPEG |

### Misc
| Alias | Script | Description |
|-------|--------|-------------|
| `r` | `temp-script-edit-run` | Edit & run temp script |
| `jv` | `json-validate-pretty` | Validate & format JSON |
| `sz` | `disk-usage-summary` | Disk usage summary |
| `pport` | `port-show-process` | Show process on port |
| `re` | `list-recent-files` | Recent files |
| `rp` | `repo-print` | Print repo info |

## Tmux

Prefix: `C-a` (not `C-b`)

### Key Bindings
- `C-a h/j/k/l` - Navigate panes (vim-style)
- `C-a |` - Split vertical
- `C-a -` - Split horizontal
- `C-a z` - Open zshrc
- `C-a b` - Git branch selector
- `C-a g` - Google search
- `C-a p` - Create PR
- `C-a G` - GPU monitor (nvidia-smi)

### Project Shortcuts
`C-a` + number jumps to project tmux sessions.

## Nix Infrastructure

Declarative, reproducible setup using Nix flakes.

```bash
make switch          # Apply config
make update          # Update all inputs
make gc              # Garbage collect (keep 7 days)
make search q=ripgrep  # Search packages
make rollback        # Revert to previous
```

### Structure
- `flake.nix` - Entry point
- `home/default.nix` - Shared packages & config
- `darwin/default.nix` - macOS-specific (nix-darwin)

### Included Packages
ripgrep, fd, fzf, jq, tree, htop, btop, git, gh, lazygit, neovim, tmux, nodejs, python, go, yarn, cmake, gcc, bat, eza, delta, zoxide

## Editors

### Neovim
- Plugin manager: lazy.nvim
- Config: `nvim/init.lua` + `nvim/lua/`
- Ripgrep integration for `:grep`

### Ranger
- File manager with preview support
- Config: `ranger/rc.conf`

## macOS Notes

1. **Key repeat**: Set to maximum speed in System Preferences
2. **iTerm2**: Configure to use `~/.config/iterm2` for settings
3. **Font**: Manually install JetBrains Mono
4. **Karabiner**: Config at `karabiner/karabiner.json`
5. **Aerospace**: Tiling WM config at `aerospace/aerospace.toml`

## Git Policy

This repo uses a **whitelist .gitignore** - everything is ignored by default. Explicitly add files you want tracked:

```gitignore
# .gitignore
*
!.gitignore
!zshrc
!bin/scripts/my-new-script
```

## Testing

```bash
make check           # Validate flake
make build           # Build without activating
make docker-test     # Test in Docker container
```

## File Locations

| Config | Location |
|--------|----------|
| Shell | `~/.config/zshrc` (symlinked to `~/.zshrc`) |
| Neovim | `~/.config/nvim/` |
| Tmux | `~/.config/tmux/tmux.conf` |
| SSH keys | `~/.ssh/` (not in repo) |
| Mac tmp | `~/.mactmp/` (cached remote files) |
