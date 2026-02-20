# Jamie's dotfiles - Nix edition
# Usage: just <recipe>

hostname := `hostname`
username := `whoami`
system := `uname -s`
arch := `uname -m`

nix_system := if system == "Darwin" {
    if arch == "arm64" { "aarch64-darwin" } else { "x86_64-darwin" }
} else {
    "x86_64-linux"
}

darwin_host := if system == "Darwin" {
    if arch == "arm64" { "daily-driver" } else { "pondhq-server" }
} else {
    ""
}

# Show available recipes
default:
    @just --list

# ============================================================================
# Setup
# ============================================================================

# First-time setup (requires nix to be installed)
setup:
    @command -v nix >/dev/null 2>&1 || { echo "Error: Nix is not installed. Install it first: https://nixos.org/download"; exit 1; }
    @if [ "{{ system }}" = "Darwin" ]; then \
        just install-darwin; \
    else \
        just install-hm; \
        just tailscale; \
    fi

# Bootstrap nix-darwin (macOS)
install-darwin:
    @if [ "{{ system }}" != "Darwin" ]; then echo "nix-darwin is macOS only"; exit 1; fi
    @echo "Bootstrapping nix-darwin..."
    @just darwin-switch

# Bootstrap home-manager (Linux)
install-hm:
    @echo "Bootstrapping home-manager for {{ username }}@{{ hostname }}..."
    nix run home-manager -- switch --flake .#{{ username }}@{{ hostname }}

# Install Tailscale daemon (Linux - macOS uses nix-darwin service)
tailscale:
    #!/usr/bin/env bash
    if [ "{{ system }}" = "Darwin" ]; then
        echo "Tailscale is managed by nix-darwin (services.tailscale.enable). Run: just darwin-switch"
        exit 0
    fi
    if command -v tailscaled >/dev/null 2>&1 && systemctl is-active --quiet tailscaled; then
        echo "Tailscale is already installed and running."
    else
        echo "Installing Tailscale..."
        curl -fsSL https://tailscale.com/install.sh | sh
        echo ""
        echo "Tailscale installed. Run: sudo tailscale up --ssh"
    fi

# ============================================================================
# Daily use
# ============================================================================

# Apply config for current machine
switch:
    @if [ "{{ system }}" = "Darwin" ]; then \
        just darwin-switch; \
    else \
        home-manager switch --flake .#{{ username }}@{{ hostname }}; \
    fi

# Apply config with verbose output
switch-debug:
    @if [ "{{ system }}" = "Darwin" ]; then \
        just darwin-switch-debug; \
    else \
        home-manager switch --flake .#{{ username }}@{{ hostname }} --show-trace; \
    fi

# Build darwin config without activating
darwin-build:
    @if [ "{{ system }}" != "Darwin" ]; then echo "darwin-build is macOS only"; exit 1; fi
    nix build .#darwinConfigurations.{{ darwin_host }}.system

# Activate darwin config (requires sudo)
darwin-activate:
    @if [ "{{ system }}" != "Darwin" ]; then echo "darwin-activate is macOS only"; exit 1; fi
    sudo ./result/sw/bin/darwin-rebuild switch --flake .#{{ darwin_host }}

# Build and activate darwin config
darwin-switch: darwin-build darwin-activate

# Build and activate darwin config with verbose output
darwin-switch-debug:
    @if [ "{{ system }}" != "Darwin" ]; then echo "darwin-switch-debug is macOS only"; exit 1; fi
    nix build .#darwinConfigurations.{{ darwin_host }}.system --show-trace
    sudo ./result/sw/bin/darwin-rebuild switch --flake .#{{ darwin_host }} --show-trace

# Update all flake inputs
update:
    nix flake update

# Update only nixpkgs
update-nixpkgs:
    nix flake lock --update-input nixpkgs

# Update only home-manager
update-home-manager:
    nix flake lock --update-input home-manager

# ============================================================================
# Maintenance
# ============================================================================

# Garbage collect old generations (keeps 7 days)
gc:
    nix-collect-garbage --delete-older-than 7d

# Aggressive garbage collection (deletes everything unused)
gc-all:
    nix-collect-garbage -d
    nix-store --optimise

# List home-manager generations
generations:
    home-manager generations

# Rollback to previous generation
rollback:
    #!/usr/bin/env bash
    if [ "{{ system }}" = "Darwin" ]; then
        darwin-rebuild --rollback
    else
        home-manager generations | head -2 | tail -1 | awk '{print $NF}' | xargs -I {} home-manager switch --flake {}
    fi

# ============================================================================
# Quick edit
# ============================================================================

# Edit packages in $EDITOR, then rebuild
edit:
    ${EDITOR:-nvim} home/default.nix && just switch

# Edit darwin config in $EDITOR, then rebuild
edit-darwin:
    ${EDITOR:-nvim} darwin/default.nix && just darwin-switch

# ============================================================================
# Symlinks
# ============================================================================

# Symlink GLOBAL_AGENTS.md -> ~/.claude/CLAUDE.md
link-global-agents:
    ln -sf {{ justfile_directory() }}/GLOBAL_AGENTS.md {{ env("HOME") }}/.claude/CLAUDE.md
    @echo "Linked {{ env("HOME") }}/.claude/CLAUDE.md -> {{ justfile_directory() }}/GLOBAL_AGENTS.md"

# ============================================================================
# Search & explore
# ============================================================================

# Search nixpkgs (usage: just search ripgrep)
search q:
    nix search nixpkgs {{ q }}

# Open nix repl with flake
repl:
    nix repl .

# List available dev shells
shells:
    @nix flake show --json 2>/dev/null | jq -r '.devShells | to_entries[] | "\(.key): \(.value | keys | join(", "))"'

# Show why a package is installed (usage: just why gcc)
why p:
    nix why-depends ~/.nix-profile {{ p }}

# ============================================================================
# Testing
# ============================================================================

# Validate flake without building
check:
    nix flake check

# Build config without activating
build:
    @if [ "{{ system }}" = "Darwin" ]; then \
        nix build .#darwinConfigurations.{{ darwin_host }}.system; \
    else \
        nix build .#homeConfigurations.{{ username }}@{{ hostname }}.activationPackage; \
    fi

# Run setup tests
test:
    @bash ./test_setup.sh

# Build Docker test image (x86_64)
docker-build:
    DOCKER_BUILDKIT=1 docker build --platform linux/amd64 -t dotfiles-test .

# Run full test in Docker container (x86_64)
docker-test:
    DOCKER_BUILDKIT=1 docker build --platform linux/amd64 -t dotfiles-test .
    docker run --platform linux/amd64 --rm dotfiles-test

# Interactive shell in test container (x86_64)
docker-shell:
    DOCKER_BUILDKIT=1 docker build --platform linux/amd64 -t dotfiles-test .
    docker run --platform linux/amd64 --rm -it dotfiles-test

# Run container without rebuilding
docker-run:
    docker run --platform linux/amd64 --rm -it dotfiles-test

# ============================================================================
# CI
# ============================================================================

# Run CI checks (used by GitHub Actions)
ci:
    @echo "==> Checking flake..."
    nix flake check
    @echo "==> Building home-manager config..."
    nix build .#homeConfigurations.jamie@ci.activationPackage --no-link
    @echo "==> All checks passed!"

# ============================================================================
# Info
# ============================================================================

# Show current system info
info:
    @echo "System:   {{ system }}"
    @echo "Arch:     {{ nix_system }}"
    @echo "Hostname: {{ hostname }}"
    @echo "Username: {{ username }}"
    @echo ""
    @echo "Nix version:"
    @nix --version 2>/dev/null || echo "  (not installed)"
    @echo ""
    @echo "Flake inputs:"
    @nix flake metadata 2>/dev/null | grep -A 100 "Inputs:" || echo "  (flake not initialized)"
