#!/usr/bin/env bash
#
# Bootstrap a fresh Ubuntu machine to a fully working dev environment.
# Run: curl -fsSL https://raw.githubusercontent.com/jamierpond/.config/main/setup.sh | bash
#
# Or locally: ./setup.sh
#
set -euo pipefail

# Source Nix if already installed (needed for Docker where each RUN is a new shell)
if [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
elif [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
  . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# =============================================================================
# Config
# =============================================================================

DOTFILES_REPO="https://github.com/jamierpond/.config.git"
DOTFILES_DIR="$HOME/.config"
PROJECTS_DIR="$HOME/projects"

# Repos to clone (path:repo_url)
REPOS=(
  "yapi:https://github.com/jamierpond/yapi.git"
)

# =============================================================================
# Checks
# =============================================================================

info "Starting bootstrap..."

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
  info "Detected macOS"
elif [[ -f /etc/os-release ]]; then
  OS="linux"
  info "Detected Linux"
else
  error "Unsupported OS"
fi

# =============================================================================
# Install Nix
# =============================================================================

if command -v nix &> /dev/null; then
  info "Nix already installed: $(nix --version)"
else
  info "Installing Nix..."

  # Detect if we're in Docker/container (no systemd)
  IS_CONTAINER=false
  if [[ -f /.dockerenv ]] || [[ ! -d /run/systemd/system ]]; then
    IS_CONTAINER=true
  fi

  # Use Determinate Systems installer - better maintained, works everywhere
  if [[ "$IS_CONTAINER" == true ]]; then
    info "Container detected, using Determinate installer (no daemon)..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux --no-confirm --init none
  elif [[ "$OS" == "macos" ]]; then
    info "Installing Nix via Determinate installer..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
  else
    info "Installing Nix via Determinate installer..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
  fi

  # Source nix
  if [[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  elif [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
    . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  fi
fi

# Enable flakes (if not already enabled above)
mkdir -p "$HOME/.config/nix"
if ! grep -q "experimental-features" "$HOME/.config/nix/nix.conf" 2>/dev/null; then
  info "Enabling Nix flakes..."
  echo "experimental-features = nix-command flakes" >> "$HOME/.config/nix/nix.conf"
fi

# =============================================================================
# Clone dotfiles
# =============================================================================

if [[ -d "$DOTFILES_DIR/.git" ]]; then
  info "Dotfiles already cloned at $DOTFILES_DIR"
  cd "$DOTFILES_DIR"
  git pull --rebase || warn "Could not pull latest dotfiles"
else
  info "Cloning dotfiles..."
  # Backup existing .config if it exists
  if [[ -d "$DOTFILES_DIR" ]]; then
    warn "Backing up existing $DOTFILES_DIR to $DOTFILES_DIR.bak"
    mv "$DOTFILES_DIR" "$DOTFILES_DIR.bak"
  fi
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  cd "$DOTFILES_DIR"
fi

# =============================================================================
# Clone project repos
# =============================================================================

info "Setting up project repos..."
mkdir -p "$PROJECTS_DIR"

for repo_spec in "${REPOS[@]}"; do
  name="${repo_spec%%:*}"
  url="${repo_spec#*:}"
  target="$PROJECTS_DIR/$name"

  if [[ -d "$target" ]]; then
    info "  $name already exists"
  else
    info "  Cloning $name..."
    git clone "$url" "$target" || warn "Could not clone $name"
  fi
done

# =============================================================================
# Apply home-manager config
# =============================================================================

info "Applying home-manager configuration..."

# Determine the flake config to use
HOSTNAME=$(hostname)
FLAKE_CONFIG="$USER@$HOSTNAME"

# Check if this host has a config, otherwise use CI config
if ! nix flake show --json 2>/dev/null | grep -q "\"$FLAKE_CONFIG\""; then
  warn "No config for $FLAKE_CONFIG, using jamie@ci"
  FLAKE_CONFIG="jamie@ci"
fi

# Build and activate
if [[ "$OS" == "macos" ]]; then
  # Check if nix-darwin is already installed
  if command -v darwin-rebuild &> /dev/null; then
    info "Running darwin-rebuild..."
    darwin-rebuild switch --flake ".#macbook"
  else
    info "Bootstrapping nix-darwin (this will take a moment)..."
    # Build first, then activate with the built darwin-rebuild
    nix build .#darwinConfigurations.macbook.system
    ./result/bin/darwin-rebuild switch --flake .#macbook
  fi
else
  info "Running home-manager..."
  nix run home-manager -- switch --flake ".#$FLAKE_CONFIG"
fi

# =============================================================================
# Post-install
# =============================================================================

info "Running post-install steps..."

# Set zsh as default shell if not already
if [[ "$SHELL" != *"zsh"* ]]; then
  ZSH_PATH="$HOME/.nix-profile/bin/zsh"
  if [[ -x "$ZSH_PATH" ]]; then
    info "Setting zsh as default shell..."
    if ! grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
      echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null || warn "Could not add zsh to /etc/shells"
    fi
    chsh -s "$ZSH_PATH" || warn "Could not change shell (run: chsh -s $ZSH_PATH)"
  fi
fi

# =============================================================================
# Done
# =============================================================================

echo ""
info "=========================================="
info " Bootstrap complete!"
info "=========================================="
echo ""
echo "Next steps:"
echo "  1. Restart your terminal (or run: exec zsh)"
echo "  2. Verify with: make info"
echo ""
if [[ "$OS" == "macos" ]]; then
  echo "For macOS system settings, run:"
  echo "  darwin-rebuild switch --flake ~/.config#macbook"
  echo ""
fi
