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

# A first install has no home-manager on PATH yet, so run it from the flake registry.
home_manager := `command -v home-manager || echo "nix run home-manager --"`

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
    @just switch
    @if [ "{{ system }}" != "Darwin" ]; then just tailscale; fi

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
        {{ home_manager }} switch --flake .#{{ username }}@{{ hostname }}; \
    fi

# Apply config with verbose output
switch-debug:
    @if [ "{{ system }}" = "Darwin" ]; then \
        just darwin-switch-debug; \
    else \
        {{ home_manager }} switch --flake .#{{ username }}@{{ hostname }} --show-trace; \
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

# Switch to tamby (ARM Mac Mini) config
tamby:
    @if [ "{{ system }}" != "Darwin" ]; then echo "tamby is macOS only"; exit 1; fi
    nix build .#darwinConfigurations.tamby.system
    sudo ./result/sw/bin/darwin-rebuild switch --flake .#tamby

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
    nix flake update nixpkgs

# Update only home-manager
update-home-manager:
    nix flake update home-manager

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
    set -euo pipefail
    if [ "{{ system }}" = "Darwin" ]; then
        sudo darwin-rebuild switch --rollback
    else
        # Lines read "<date> <time> : id <n> -> <store path>", newest first.
        previous_generation=$(home-manager generations | sed -n 2p | awk '{print $NF}')
        [ -n "$previous_generation" ] || { echo "No previous home-manager generation"; exit 1; }
        "$previous_generation/activate"
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
        just darwin-build; \
    else \
        nix build .#homeConfigurations.{{ username }}@{{ hostname }}.activationPackage; \
    fi

# Build Docker test image (x86_64)
docker-build:
    DOCKER_BUILDKIT=1 docker build --platform linux/amd64 -t dotfiles-test .

# Run full test in Docker container (x86_64)
docker-test: docker-build
    docker run --platform linux/amd64 --rm dotfiles-test

# Interactive shell in test container (x86_64)
docker-shell: docker-build
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

# Make ~/.config/claude the Claude Code config dir and link per-repo memory (see claude/README.md)
claude-sync:
    bin/scripts/claude-sync

# Fetch this project's Claude Code sessions from every online Tailscale machine, newest file wins. Run as `just -f ~/.config/justfile claude-session-pull` from the project, or pass its directory.
claude-session-pull project_directory=invocation_directory():
    bin/scripts/claude-session-sync pull "{{ project_directory }}"

# Send this project's Claude Code sessions to every online Tailscale machine, newest file wins.
claude-session-push project_directory=invocation_directory():
    bin/scripts/claude-session-sync push "{{ project_directory }}"

# Make a standard, key-only ssh account on a Windows machine; with a public key file, install that key
windows-add-ssh-user destination user *public_key_file:
    bin/scripts/windows-add-ssh-user {{destination}} {{user}} {{public_key_file}}
