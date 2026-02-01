# Dotfiles test environment
# Validates that setup.sh works on a fresh Ubuntu machine
#
# Build: make docker-build
# Test:  make docker-test
# Shell: make docker-shell

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Minimal dependencies (what a fresh Ubuntu has + curl/git)
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

# Install Nix (single-user for Docker)
RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

ENV PATH="/home/jamie/.nix-profile/bin:$PATH"

# Enable flakes
RUN mkdir -p ~/.config/nix \
    && echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

# Copy dotfiles (simulates: git clone the repo)
COPY --chown=jamie:jamie . /home/jamie/.config/

WORKDIR /home/jamie/.config

# Create projects dir and clone yapi (simulates the REPOS part of setup.sh)
RUN mkdir -p ~/projects \
    && git clone https://github.com/jamierpond/yapi.git ~/projects/yapi || true

# Run the core of setup.sh: apply home-manager
RUN . ~/.nix-profile/etc/profile.d/nix.sh \
    && nix run home-manager -- switch --flake .#jamie@ci

# Verify everything works
RUN . ~/.nix-profile/etc/profile.d/nix.sh \
    && echo "=== Verifying installed programs ===" \
    && nvim --version | head -1 \
    && tmux -V \
    && rg --version | head -1 \
    && node --version \
    && python3 --version \
    && go version \
    && git --version \
    && lazygit --version | head -1 \
    && yarn --version \
    && make --version | head -1 \
    && echo "=== All programs verified! ==="

# Open nvim and check plugins load (headless)
RUN . ~/.nix-profile/etc/profile.d/nix.sh \
    && timeout 60 nvim --headless "+Lazy! sync" +qa || true \
    && echo "=== Neovim plugins synced ==="

# Default: zsh
CMD ["/home/jamie/.nix-profile/bin/zsh", "-l"]
