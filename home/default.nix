{ config, pkgs, lib, ... }:

{
  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Packages to install
  home.packages = with pkgs; [
    # ==========================================================================
    # CLI essentials
    # ==========================================================================
    ripgrep
    fd
    fzf
    jq
    tree
    htop
    btop
    wget
    curl
    rsync
    unzip
    zip
    file
    killall          # psmisc - needed by xbase
    watch
    entr             # run commands on file change

    # ==========================================================================
    # Dev tools
    # ==========================================================================
    git
    gh
    lazygit
    neovim
    tmux
    ranger
    delta            # better git diffs

    # ==========================================================================
    # Languages & runtimes
    # ==========================================================================
    # Node.js
    nodejs_20
    pnpm
    yarn

    # Python
    python312
    uv               # fast python package manager

    # Go
    go

    # Rust
    rustup           # manages rust toolchains, provides cargo

    # ==========================================================================
    # Build tools & compilers
    # ==========================================================================
    gnumake
    cmake
    ninja            # fast build system
    bazel
    pkg-config
    protobuf         # protoc

    # C/C++ toolchain
    gcc
    llvm
    lld              # fast linker
    clang-tools      # clangd, clang-format, etc. (no cc conflict)

    # ==========================================================================
    # Media & misc
    # ==========================================================================
    ffmpeg
    sox
    imagemagick

    # ==========================================================================
    # Cloud & infrastructure
    # ==========================================================================
    cloudflared      # Cloudflare tunnel
    # docker         # usually installed system-wide

    # ==========================================================================
    # Nice to have
    # ==========================================================================
    bat              # better cat
    eza              # better ls
    zoxide           # smart cd
    tldr             # simplified man pages
    hyperfine        # benchmarking
    tokei            # code stats
    dust             # better du
    duf              # better df
    procs            # better ps
    sd               # better sed
    choose           # better cut
    difftastic       # structural diff
  ];

  # Git config
  programs.git = {
    enable = true;
    settings = {
      user.name = "Jamie Pond";
      user.email = "jamiepond259@gmail.com";
      init.defaultBranch = "main";
      credential.helper = "${pkgs.gh}/bin/gh auth git-credential";
      push.autoSetupRemote = true;
    };
  };

  # Delta (better git diffs)
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  # Zsh config
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Source your existing config (gradual migration)
    initContent = ''
      # Source existing config if it exists
      [[ -f ~/.config/zshrc ]] && source ~/.config/zshrc
    '';

    shellAliases = {
      ll = "eza -la";
      cat = "bat";
      lg = "lazygit";
    };
  };

  # Fzf integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Zoxide (smart cd)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Home-manager state version (don't change after initial setup)
  home.stateVersion = "24.05";
}
