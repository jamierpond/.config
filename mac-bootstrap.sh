#!/usr/bin/env bash
#
# mac-bootstrap.sh — Bring a fresh macOS (Apple Silicon) machine to a full dev
# environment using Jamie's Nix + nix-darwin dotfiles.
#
# Run on a brand-new Mac:
#   curl -fsSL https://raw.githubusercontent.com/jamierpond/.config/main/mac-bootstrap.sh | bash
# Or, if you already have this file:
#   bash ~/mac-bootstrap.sh
#
# Idempotent: safe to re-run. Each step is skipped if already done.
# You WILL be prompted for your password (sudo) by the Nix installer and by
# darwin-rebuild. That is expected.
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
DOTFILES_REPO="https://github.com/jamierpond/.config.git"
DOTFILES_DIR="$HOME/.config"
PROJECTS_DIR="$HOME/projects"

# Project repos to clone (name:url)
REPOS=(
  "yapi:https://github.com/jamierpond/yapi.git"
)

# Pick the nix-darwin host. Override with: DARWIN_HOST=tamby bash mac-bootstrap.sh
ARCH="$(uname -m)"
if [[ "$ARCH" == "arm64" ]]; then
  DARWIN_HOST="${DARWIN_HOST:-daily-driver}"   # ARM MacBook / daily driver
else
  DARWIN_HOST="${DARWIN_HOST:-pondhq-server}"  # Intel Mac
fi

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || error "This script is macOS-only."

info "Target host config: .#${DARWIN_HOST}  (arch: ${ARCH})"

# ---------------------------------------------------------------------------
# 1. Xcode Command Line Tools (provides git, clang, headers)
# ---------------------------------------------------------------------------
if xcode-select -p >/dev/null 2>&1; then
  info "Command Line Tools already installed."
else
  info "Installing Xcode Command Line Tools..."
  # Headless install: trick softwareupdate into listing the CLT package.
  CLT_PLACEHOLDER="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
  touch "$CLT_PLACEHOLDER"
  PROD="$(softwareupdate -l 2>/dev/null \
    | grep -B1 -E 'Command Line Tools' \
    | awk -F'Label: ' '/Label:/ {print $2}' \
    | sort -V | tail -n1)"
  if [[ -n "$PROD" ]]; then
    info "  Installing: $PROD (this can take several minutes)..."
    softwareupdate -i "$PROD" --verbose || warn "softwareupdate CLT install hiccupped; will verify below."
  else
    warn "  Could not resolve CLT label headlessly; opening the GUI installer."
    xcode-select --install || true
  fi
  rm -f "$CLT_PLACEHOLDER"

  # Wait until the tools actually exist (covers the GUI-dialog path too).
  info "  Waiting for Command Line Tools to finish installing..."
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
  info "  Command Line Tools installed."
fi

# ---------------------------------------------------------------------------
# 2. Nix (Determinate Systems installer) + flakes
# ---------------------------------------------------------------------------
# Make nix available in THIS shell if it's already installed.
if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

if command -v nix >/dev/null 2>&1; then
  info "Nix already installed: $(nix --version)"
else
  info "Installing Nix (Determinate installer — will ask for your password)..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Ensure flakes are enabled (Determinate enables them, but be defensive).
mkdir -p "$HOME/.config/nix"
if ! grep -qs "experimental-features" "$HOME/.config/nix/nix.conf" 2>/dev/null; then
  echo "experimental-features = nix-command flakes" >> "$HOME/.config/nix/nix.conf"
  info "Enabled nix-command + flakes."
fi

command -v nix >/dev/null 2>&1 || error "Nix not on PATH after install. Open a new terminal and re-run."

# ---------------------------------------------------------------------------
# 3. Clone (or update) dotfiles into ~/.config
# ---------------------------------------------------------------------------
# NOTE: this script may itself live at ~/.config/mac-bootstrap.sh once the repo
# is cloned. If ~/.config already exists but is NOT a git repo, back it up.
if [[ -d "$DOTFILES_DIR/.git" ]]; then
  info "Dotfiles already present at $DOTFILES_DIR — pulling latest."
  git -C "$DOTFILES_DIR" pull --ff-only || warn "Could not fast-forward dotfiles; leaving as-is."
else
  if [[ -d "$DOTFILES_DIR" ]] && [[ -n "$(ls -A "$DOTFILES_DIR" 2>/dev/null)" ]]; then
    warn "Backing up existing $DOTFILES_DIR -> ${DOTFILES_DIR}.bak"
    rm -rf "${DOTFILES_DIR}.bak"
    mv "$DOTFILES_DIR" "${DOTFILES_DIR}.bak"
  fi
  info "Cloning dotfiles..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# ---------------------------------------------------------------------------
# 4. Clone project repos into ~/projects
# ---------------------------------------------------------------------------
mkdir -p "$PROJECTS_DIR"
for spec in "${REPOS[@]}"; do
  name="${spec%%:*}"; url="${spec#*:}"; target="$PROJECTS_DIR/$name"
  if [[ -d "$target/.git" ]]; then
    info "Project $name already cloned."
  else
    info "Cloning project $name..."
    git clone "$url" "$target" || warn "Could not clone $name (skipping)."
  fi
done

# ---------------------------------------------------------------------------
# 4b. Homebrew (required by the nix-darwin `homebrew` module for GUI/driver
#     apps: AeroSpace, Karabiner-Elements). Activation ABORTS if brew is
#     missing, so it must be installed BEFORE darwin-switch.
# ---------------------------------------------------------------------------
BREW_PREFIX="/opt/homebrew"; [[ "$ARCH" != "arm64" ]] && BREW_PREFIX="/usr/local"

if [[ -x "$BREW_PREFIX/bin/brew" ]]; then
  info "Homebrew already installed."
else
  info "Installing Homebrew (will ask for your password)..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$("$BREW_PREFIX/bin/brew" shellenv)"

# Homebrew 6+ refuses casks from third-party taps until explicitly trusted.
# nix-darwin cannot do this, so trust them here before `brew bundle` runs.
TRUSTED_TAPS=(
  "nikitabobko/tap"   # AeroSpace
)
for tap in "${TRUSTED_TAPS[@]}"; do
  info "Trusting tap: $tap"
  brew trust "$tap" 2>/dev/null || warn "Could not trust $tap (may be fine if already trusted)."
done

# ---------------------------------------------------------------------------
# 5. Build + activate the nix-darwin system config
# ---------------------------------------------------------------------------
cd "$DOTFILES_DIR"

# Sanity-check the host actually exists in the flake before building.
if ! nix eval --raw ".#darwinConfigurations.${DARWIN_HOST}.system.outPath" >/dev/null 2>&1; then
  error "Flake has no darwin host '${DARWIN_HOST}'. Available hosts: $(nix eval --json '.#darwinConfigurations' --apply builtins.attrNames 2>/dev/null || echo '???'). Set DARWIN_HOST=... and re-run."
fi

if command -v darwin-rebuild >/dev/null 2>&1; then
  info "Activating darwin config (.#${DARWIN_HOST}) — will ask for your password..."
  sudo darwin-rebuild switch --flake ".#${DARWIN_HOST}"
else
  info "First-time nix-darwin bootstrap: building .#${DARWIN_HOST} ..."
  nix build ".#darwinConfigurations.${DARWIN_HOST}.system"
  info "Activating (will ask for your password)..."
  sudo ./result/sw/bin/darwin-rebuild switch --flake ".#${DARWIN_HOST}"
fi

# ---------------------------------------------------------------------------
# 6. Done
# ---------------------------------------------------------------------------
echo ""
info "=========================================="
info " Bootstrap complete for .#${DARWIN_HOST}"
info "=========================================="
echo ""
echo "Next:"
echo "  1. Open a new terminal (or: exec zsh) to load the new shell config."
echo "  2. Verify with: cd ~/.config && make info"
echo "  3. Day-to-day: edit ~/.config/home/default.nix then 'make switch'."
echo ""
