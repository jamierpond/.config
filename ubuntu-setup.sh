#!/bin/bash
set -ex


# assumes curl and sudo are available

# Install GH CLI directly via a package manager instead of manual setup
if ! command -v gh &>/dev/null; then
  echo "Installing GitHub CLI..."
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |
    sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
fi

# Define a list of packages along with their expected verification commands
PACKAGES=(
  "build-essential:g++"      # build-essential should be verified by checking g++
  "nodejs:node"              # nodejs package provides the node command
  "npm:npm"                  # npm package provides the npm command
  "unzip:unzip"
  "zip:zip"
  "fzf:fzf"
  "ripgrep:rg"
  "snapd:snap"
  "ffmpeg:ffmpeg"
  "sox:sox"
  "libsox-dev:sox"           # libsox-dev provides the sox command too
  "pkg-config:pkg-config"
  "protobuf-compiler:protoc" # Verify protobuf-compiler via protoc
  "cmake:cmake"
  "linux-libc-dev:"          # No direct command to verify, will skip
  "clang:clang"
  "git-secret:git-secret"
  "libomp-dev:"              # No direct command to verify
  "ranger:ranger"
  "zsh:zsh"
  "jq:jq"
  "gh:gh"
  "wget:wget"
  "rsync:rsync"
)



# Install necessary packages
echo "Installing required packages..."
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive TZ=America/Los_Angeles apt-get -y install tzdata
sudo apt install -y $(printf "%s " "${PACKAGES[@]%%:*}")  # Extract package names only

# Uncomment if snap installations are needed
# sudo snap install docker go tmux nvim

# Install LazyGit =======================================================================
echo "Installing LazyGit..."
TMP_DIR=$(mktemp -d)
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | jq -r .tag_name | sed 's/^v//')
LAZYGIT_URL="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"

wget -qO "$TMP_DIR/lazygit.tar.gz" "$LAZYGIT_URL"
tar -xf "$TMP_DIR/lazygit.tar.gz" -C "$TMP_DIR" lazygit
sudo install "$TMP_DIR/lazygit" /usr/local/bin
rm -rf "$TMP_DIR"


# Install Neovim =======================================================================
TMP_DIR=$(mktemp -d)
NVIM_URL=https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz
wget -qO "$TMP_DIR/nvim.tar.gz" "$NVIM_URL"
tar -xf "$TMP_DIR/nvim.tar.gz" -C "$TMP_DIR"
sudo cp -r "$TMP_DIR/nvim-linux-x86_64/bin/" /usr/local/
rm -rf "$TMP_DIR"


# Clone dotfiles only if necessary
CONFIG_DIR="$HOME/.config"
if [ ! -d "$CONFIG_DIR/.git" ]; then
  echo "Cloning dotfiles..."
  git clone https://github.com/jamierpond/.config "$HOME/jamie-config"
  mkdir -p "$CONFIG_DIR"
  rsync -av --ignore-existing "$HOME/jamie-config/" "$CONFIG_DIR/"
else
  echo "Dotfiles already exist, skipping clone."
fi

# Configure Git
git config --global user.email "jamiepond259@gmail.com"
git config --global user.name "Jamie Pond"


# ========================
# Installation Verification
# ========================

echo -e "\nVerifying installations..."

# Function to check if a command exists
check_command() {
  if [ -n "$2" ]; then
    if command -v "$2" &>/dev/null; then
      echo "[✔] $1 ($2) is installed"
    else
      echo "[✘] $1 ($2) is NOT installed"
    fi
  else
    echo "[?] $1 (probably) installed but no direct command to verify"
  fi
}

# Loop through the package list and verify each one
for package_tuple in "${PACKAGES[@]}"; do
  package="${package_tuple%%:*}"  # Extract package name
  command="${package_tuple#*:}"   # Extract associated command (if any)
  check_command "$package" "$command"
done

# install pyenv
curl -fsSL https://pyenv.run | bash

# Verify LazyGit separately
check_command "lazygit" "lazygit"
check_command "pyenv" "pyenv"
check_command "nvim" "nvim"

echo -e "\nVerification complete."


