#!/bin/bash
set -e

cd "$HOME" || exit
# todo just make this using a token
# install gh cli
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \

# install boring things we probably need
sudo apt update && sudo apt install -y build-essential nodejs npm unzip zip    \
  fzf ripgrep snapd ffmpeg sox libsox-dev pkg-config protobuf-compiler cmake   \
  linux-libc-dev clang git-secret libomp-dev ranger zsh jq gh -y

# sudo snap install docker go tmux nvim

rm -rf ./lazygit-tmp
mkdir -p ./lazygit-tmp
cd ./lazygit-tmp
lg_version=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | jq -r .tag_name)
LAZYGIT_VERSION=${lg_version#v}
echo "Latest lazygit version is ${LAZYGIT_VERSION}"
LAZYGIT_URL="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
echo "Downloading lazygit version ${LAZYGIT_VERSION}"
echo "Downloading lazygit from ${LAZYGIT_URL}"
rm -rf lazygit.tar.gz lazygit
curl -Lo lazygit.tar.gz $LAZYGIT_URL
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
cd ..
rm -rf ./lazygit-tmp


# TODO make this also copy the dotfiles (.git and .gitignore)
# if the .config already exits then skip cloning it, else clone
# CONFIG_DIR="$HOME/.config"
CONFIG_DIR="$HOME/test-config"
if [ ! -e "$CONFIG_DIR/.git" ]; then
  echo "need to clone"
  rm -rf ~/jamie-config
  git clone https://github.com/jamierpond/.config ~/jamie-config
  mkdir -p "$CONFIG_DIR"
  cp -r ~/jamie-config/* "$CONFIG_DIR"
else
  echo "not recloning"
fi

gh auth status
if [ $? -eq 0 || "$CI" = "true" ]; then
  echo "Already logged in to gh, skipping"
else
  gh auth login
  gh auth setup-git
fi

# setup git
git config --global user.email "jamiepond259@gmail.com"
git config --global user.name "Jamie Pond"

file "$HOME/.config/zshrc"
source "$HOME/.config/zshrc"
