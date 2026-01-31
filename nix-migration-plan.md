# Nix Migration Plan

## Current State

- **Dotfiles**: Git repo at `~/.config` (https://github.com/jamierpond/.config)
- **Platforms**: macOS (primary) + Ubuntu (secondary)
- **Shell**: Zsh with custom config (migrated away from oh-my-zsh for speed)
- **Key configs**: nvim, tmux, ranger, lazygit, zsh aliases/functions
- **macOS-specific**: karabiner, aerospace, skhd, yabai, iterm2
- **Version managers**: nvm (885MB!), pyenv, cargo

## Proposed Nix Stack

| Platform | Tool | Purpose |
|----------|------|---------|
| Both | **Nix** | Package manager |
| Both | **home-manager** | Dotfiles + user packages |
| Both | **Flakes** | Reproducible, lockfile-based config |
| macOS | **nix-darwin** | System-level macOS config |

## Directory Structure

```
~/.config/
├── flake.nix                 # Entry point
├── flake.lock                # Pinned versions
├── home/
│   ├── default.nix           # Shared home-manager config
│   ├── packages.nix          # Cross-platform packages
│   ├── shell.nix             # Zsh config (aliases, functions)
│   ├── nvim.nix              # Neovim config
│   ├── tmux.nix              # Tmux config
│   ├── git.nix               # Git config
│   └── darwin.nix            # macOS-specific home config
├── darwin/
│   └── default.nix           # nix-darwin system config
├── hosts/
│   ├── ubuntu.nix            # Ubuntu-specific settings
│   └── macbook.nix           # macOS-specific settings
└── (existing configs remain until migrated)
```

## Migration Phases

### Phase 1: Install Nix + Bootstrap

**macOS (primary):**
```bash
sh <(curl -L https://nixos.org/nix/install)
```

> If on macOS 15 Sequoia and you see `error: the user '_nixbld1' in the group 'nixbld' does not exist`, see [NixOS/nix#10892](https://github.com/NixOS/nix/issues/10892) for fix.

**Ubuntu (later):**
```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

**Then enable flakes:**
```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Phase 2: Minimal Flake + Home-Manager

Start with a minimal `flake.nix` that:
1. Sets up home-manager as a flake input
2. Defines one host config per machine
3. Installs a few packages to validate it works

```nix
# flake.nix (minimal starter)
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # macOS only
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }: {
    # Ubuntu config
    homeConfigurations."jamie@ubuntu" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./home ];
    };

    # macOS config
    darwinConfigurations."macbook" = darwin.lib.darwinSystem {
      system = "aarch64-darwin"; # or x86_64-darwin for Intel
      modules = [
        ./darwin
        home-manager.darwinModules.home-manager
        {
          home-manager.users.jamie = import ./home;
        }
      ];
    };
  };
}
```

### Phase 3: Migrate Configs Incrementally

| Priority | Config | Approach |
|----------|--------|----------|
| 1 | **Packages** | Replace brew/apt with `home.packages` |
| 2 | **Git** | `programs.git` with your existing settings |
| 3 | **Zsh** | `programs.zsh` + port aliases |
| 4 | **Neovim** | `programs.neovim` or keep existing lua config |
| 5 | **Tmux** | `programs.tmux` |
| 6 | **Version managers** | Replace nvm/pyenv with Nix |

### Phase 4: Replace nvm/pyenv

Nix can manage Node and Python versions directly:

```nix
# Instead of nvm
home.packages = with pkgs; [
  nodejs_20
  nodejs_18  # if you need multiple
];

# Instead of pyenv
home.packages = with pkgs; [
  python312
  python311
];
```

This eliminates 885MB of nvm overhead and startup latency.

## Benefits

1. **Reproducible**: Same packages/versions on both machines
2. **Declarative**: Config is code, easy to review changes
3. **Atomic**: Rollback instantly if something breaks
4. **Fast**: No more lazy-loading hacks for nvm/pyenv
5. **Cross-platform**: One config, two OSes

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Learning curve | Start small, migrate incrementally |
| macOS quirks | nix-darwin handles most issues |
| Existing workflow disruption | Keep old configs until Nix versions work |
| Node project compatibility | Use `nix-shell` or direnv for per-project versions |

## Commands Cheatsheet

```bash
# Apply darwin config (macOS) - this also runs home-manager
darwin-rebuild switch --flake ~/.config#macbook

# Apply home-manager config (Ubuntu - standalone)
home-manager switch --flake ~/.config#jamie@ubuntu

# Update all inputs
nix flake update

# Search packages
nix search nixpkgs ripgrep

# Try a package temporarily
nix shell nixpkgs#cowsay

# Garbage collect old generations
nix-collect-garbage -d
```

## Next Steps

1. [ ] Install Nix on macOS (see Sequoia note at top if relevant)
2. [ ] Create minimal flake.nix with nix-darwin + home-manager
3. [ ] Add a few test packages to validate
4. [ ] Migrate configs one by one (git, zsh, nvim, tmux)
5. [ ] Port to Ubuntu later (home-manager only, no darwin)

---

Ready to proceed? I can create the initial flake.nix and home-manager config.
