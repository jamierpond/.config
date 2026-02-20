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
    yq-go           # yq for YAML (Mike Farah's Go implementation)
    tree
    htop
    btop
    wget
    curl
    rsync
    unzip
    zip
    file
    watch
    entr             # run commands on file change
  ] ++ lib.optionals stdenv.isLinux [
    killall          # psmisc - Linux only (macOS has /usr/bin/killall)
  ] ++ [

    # ==========================================================================
    # Dev tools
    # ==========================================================================
    git
    git-lfs
    git-secret
    gh
    lazygit
    neovim
    tmux
    ranger
    # delta is provided by programs.delta below

    # ==========================================================================
    # Languages & runtimes
    # ==========================================================================
    # Node.js
    nodejs_22
    pnpm
    yarn

    # Python
    python312
    uv               # fast python package manager

    # Go
    go
    gopls            # Go language server
    golangci-lint    # Go linter (pre-built, avoids CGO linking issues)
    (lib.setPrio 10 gotools)  # goimports, godoc, etc. (low prio to avoid /bin/play conflict with sox)
    delve            # Go debugger

    # Rust
    rustup           # manages rust toolchains, provides cargo

    # ==========================================================================
    # Build tools & compilers
    # ==========================================================================
    just             # command runner (better make for project tasks)
    gnumake
    cmake
    ninja            # fast build system
    bazel
    pkg-config
    protobuf         # protoc

    # C/C++ toolchain (no gcc — Apple clang handles macOS frameworks; gcc is in devShells if needed)
    llvm
    lld              # fast linker
    clang-tools      # clangd, clang-format, etc. (no cc conflict)

    # ==========================================================================
    # Document typesetting
    # ==========================================================================
    (texlive.combine {
      inherit (texlive) scheme-medium
        preprint        # fullpage
        titlesec
        enumitem
        fontawesome5;
    })

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
    tailscale        # Mesh VPN — SSH to personal machines from anywhere
    # vercel         # not in nixpkgs - install via npm
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
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
    };
  };

  # Zsh config
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Source your existing config (gradual migration)
    initContent = ''
      # Disable terminal bell
      unsetopt BEEP

      # Source existing config if it exists
      [[ -f ~/.config/zshrc ]] && source ~/.config/zshrc
    '';

    shellAliases = {
      # Modern replacements (these take priority over any zshrc defaults)
      ll = "eza -la";
      ls = "eza -a";
      la = "eza -a";
      cat = "bat";
      lg = "lazygit";

      # Nix shortcuts
      nrs = "cd ~/.config && make switch && cd -";  # nix rebuild switch
      nfu = "nix flake update";                     # update flake inputs
      ngc = "nix-collect-garbage -d";               # garbage collect
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

  # Direnv - auto-load dev shells when entering directories
  # Usage: echo "use flake" > .envrc && direnv allow
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;  # faster nix integration
  };

  # Claude Code
  programs.claude-code = {
    enable = true;
    # settings = { };      # Add settings if needed
    # mcpServers = { };    # Add MCP servers if needed
  };

  # Session variables and PATH
  home.sessionVariables = {
    PNPM_HOME = "$HOME/.local/share/pnpm";
    GOPATH = "$HOME/go";
  };
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.local/share/pnpm"
    "$HOME/go/bin"
  ];

  # Home-manager state version (don't change after initial setup)
  home.stateVersion = "24.05";
}
