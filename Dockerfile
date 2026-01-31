# Dotfiles test environment
# Build: docker build -t dotfiles-test .
# Test:  docker run --rm dotfiles-test
# Shell: docker run --rm -it dotfiles-test bash

FROM ubuntu:24.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for Nix
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

# Create user (Nix multi-user install needs a real user)
RUN useradd -m -s /bin/bash jamie \
    && echo "jamie ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER jamie
WORKDIR /home/jamie
ENV USER=jamie
ENV HOME=/home/jamie

# Install Nix (single-user mode for Docker simplicity)
RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

# Set up Nix environment
ENV PATH="/home/jamie/.nix-profile/bin:/nix/var/nix/profiles/default/bin:${PATH}"
ENV NIX_PATH="nixpkgs=channel:nixpkgs-unstable"

# Enable flakes
RUN mkdir -p /home/jamie/.config/nix \
    && echo "experimental-features = nix-command flakes" > /home/jamie/.config/nix/nix.conf

# Copy dotfiles
COPY --chown=jamie:jamie . /home/jamie/.config/

WORKDIR /home/jamie/.config

# Build and activate home-manager config
RUN . /home/jamie/.nix-profile/etc/profile.d/nix.sh \
    && nix build .#homeConfigurations.jamie@ci.activationPackage -o result \
    && ./result/activate \
    && echo "=== Build and activation successful! ==="

# Verify key programs are available
RUN . /home/jamie/.nix-profile/etc/profile.d/nix.sh \
    && export PATH="$HOME/.nix-profile/bin:$PATH" \
    && echo "=== Verifying installed programs ===" \
    && nvim --version | head -1 \
    && tmux -V \
    && rg --version | head -1 \
    && fzf --version \
    && node --version \
    && python3 --version \
    && git --version \
    && lazygit --version | head -1 \
    && echo "=== All programs verified! ==="

# Default command: show what's installed
CMD ["/bin/bash", "-c", "echo '🎉 Dotfiles environment ready!' && echo '' && echo 'Installed packages:' && ls -1 ~/.nix-profile/bin | head -30 && echo '...' && echo '' && echo 'Run: docker run --rm -it dotfiles-test bash'"]
