#!/bin/bash
set -e

# install boring things we probably need
sudo apt update && sudo apt install -y build-essential nodejs npm unzip zip \
  fzf ripgrep snapd ffmpeg sox libsox-dev pkg-config protobuf-compiler cmake linux-libc-dev clang git-secret \
  libomp-dev ranger
sudo apt upgrade

LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin

# install docker
# 1. add gpg key
sudo snap install docker

# # install rust
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#
# # go
# sudo snap install go --classic

# todo just make this using a token
# install gh cli
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y

# login to gh
gh auth login
gh auth setup-git

# setup git
git config --global user.email "jamiepond259@gmail.com"
git config --global user.name "Jamie Pond"

# TODO make this also copy the dotfiles (.git and .gitignore)
rm -rf ~/jamie-config
git clone https://github.com/jamierpond/.config ~/jamie-config
cp -r ~/jamie-config/* ~/.config

# install nvims
sudo snap install tmux --classic
sudo snap install nvim --classic

# tmux alias, so we can use our config
echo "alias tmux='tmux -f ~/.config/tmux/tmux.conf'" >> ~/.bashrc


