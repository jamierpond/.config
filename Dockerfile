# Dotfiles test environment
# Validates that setup.sh works on a fresh Ubuntu machine
#
# Build: make docker-build
# Test:  make docker-test
# Shell: make docker-shell

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Minimal dependencies (what a fresh Ubuntu server has)
RUN apt-get update && apt-get install -y \
    curl \
    xz-utils \
    sudo \
    git \
    ca-certificates \
    locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Create user
RUN useradd -m -s /bin/bash jamie \
    && echo "jamie ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER jamie
WORKDIR /home/jamie
ENV USER=jamie
ENV HOME=/home/jamie

# Copy dotfiles (in real life this is: git clone)
COPY --chown=jamie:jamie . /home/jamie/.config/

# Run the setup script
RUN cd ~/.config && ./setup.sh

# Verify everything works
RUN echo "=== Verifying installed programs ===" \
    && ~/.nix-profile/bin/nvim --version | head -1 \
    && ~/.nix-profile/bin/tmux -V \
    && ~/.nix-profile/bin/rg --version | head -1 \
    && ~/.nix-profile/bin/node --version \
    && ~/.nix-profile/bin/pnpm --version \
    && ~/.nix-profile/bin/python3 --version \
    && ~/.nix-profile/bin/go version \
    && ~/.nix-profile/bin/rustup --version \
    && ~/.nix-profile/bin/git --version \
    && ~/.nix-profile/bin/lazygit --version | head -1 \
    && ~/.nix-profile/bin/cmake --version | head -1 \
    && ~/.nix-profile/bin/make --version | head -1 \
    && ~/.nix-profile/bin/clang --version | head -1 \
    && ~/.nix-profile/bin/gcc --version | head -1 \
    && ~/.nix-profile/bin/bazel --version \
    && ~/.nix-profile/bin/ffmpeg -version | head -1 \
    && ~/.nix-profile/bin/cloudflared --version \
    && ~/.nix-profile/bin/killall --version | head -1 \
    && echo "=== All programs verified! ==="

# Default: zsh
CMD ["/home/jamie/.nix-profile/bin/zsh", "-l"]
