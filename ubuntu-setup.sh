#!/bin/sh
set -e

cd "$HOME" || exit

# install boring things we probably need
sudo apt update && sudo apt install -y build-essential nodejs npm unzip zip    \
  fzf ripgrep snapd ffmpeg sox libsox-dev pkg-config protobuf-compiler cmake   \
  linux-libc-dev clang git-secret libomp-dev ranger zsh jq -y

# sudo snap install docker go tmux nvim


rm -rf ./lazygit-tmp
mkdir -p ./lazygit-tmp
cd ./lazygit-tmp
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | jq -r .tag_name)
LAZYGIT_URL="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
echo "Downloading lazygit version ${LAZYGIT_VERSION}"
echo "Downloading lazygit from ${LAZYGIT_URL}"

# tmp
exit 1

rm -rf lazygit.tar.gz lazygit
curl -Lo lazygit.tar.gz ""
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
cd ..
rm -rf ./lazygit-tmp

# todo just make this using a token
# install gh cli
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y


# TODO make this also copy the dotfiles (.git and .gitignore)
# if the .config already exits then skip cloning it, else clone
if [ ! -f ~/.config ]; then
  echo "it doesn't already exist"
  #   rm -rf ~/jamie-config
  #   git clone https://github.com/jamierpond/.config ~/jamie-config
  #   cp -r ~/jamie-config/* ~/.config
else
  echo "not recloning"
fi

# default to zsh
chsh -s $(which zsh)

# gh auth status
# if [ $? -eq 0 || "$CI" = "true" ]; then
#   echo "Already logged in to gh, skipping"
# else
#   gh auth login
#   gh auth setup-git
# fi

# setup git
git config --global user.email "jamiepond259@gmail.com"
git config --global user.name "Jamie Pond"

