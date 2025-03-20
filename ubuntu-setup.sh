#!/bin/bash
set -e

# assumes curl and sudo are available

# Install GH CLI directly via a package manager instead of manual setup
if ! command -v gh &>/dev/null; then
  echo "Installing GitHub CLI..."
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |
    sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
fi

# Install necessary packages
echo "Installing required packages..."
sudo apt update && sudo apt install -y \
  build-essential nodejs npm unzip zip fzf ripgrep snapd ffmpeg sox \
  libsox-dev pkg-config protobuf-compiler cmake linux-libc-dev clang \
  git-secret libomp-dev ranger zsh jq gh wget rsync

# Uncomment if snap installations are needed
# sudo snap install docker go tmux nvim

# Install LazyGit
echo "Installing LazyGit..."
TMP_DIR=$(mktemp -d)
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | jq -r .tag_name | sed 's/^v//')
LAZYGIT_URL="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"

wget -qO "$TMP_DIR/lazygit.tar.gz" "$LAZYGIT_URL"
tar -xf "$TMP_DIR/lazygit.tar.gz" -C "$TMP_DIR" lazygit
sudo install "$TMP_DIR/lazygit" /usr/local/bin
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

# Source ZSH configuration
[ -f "$CONFIG_DIR/zshrc" ] && source "$CONFIG_DIR/zshrc"

