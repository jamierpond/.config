{ config, pkgs, lib, ... }:

{
  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Default editor: nvim everywhere. Set at the Nix level so non-interactive
  # shells and the generated set-environment get it too (overriding the
  # nix-darwin default of nano).
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

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
    gnupg            # gpg — commit signing, git-secret backend
    gh
    graphite-cli   # gt - stacked git changes
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

    # .NET — removed: dotnet-sdk_10 pulls in Swift/LLVM source builds on macOS.
    # Install manually: brew install dotnet-sdk, or use a flake devShell per-project.

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

    # C/C++ toolchain. On macOS only clang-format is taken from clang-tools:
    # Apple ships clangd (/usr/bin/clangd, matched to the Xcode SDK), and the
    # Nix clangd injects Nix libc++/libSystem headers on top of -isysroot,
    # producing bogus diagnostics in SDK-based projects.
    (if stdenv.isDarwin then
      runCommand "clang-format-only" { } ''
        mkdir -p $out/bin
        ln -s ${clang-tools}/bin/clang-format $out/bin/clang-format
      ''
    else clang-tools)
  ] ++ lib.optionals stdenv.isLinux [
    # llvm/lld on Linux only — on macOS they shadow Apple's dsymutil/linker and break Swift builds
    llvm
    lld
  ] ++ [

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
    docker           # Docker CLI
    docker-compose   # Docker Compose
    colima           # Lightweight Docker runtime for macOS
    mongosh          # MongoDB Shell
    mongodb-tools    # mongodump, mongorestore, mongoexport, mongoimport, etc.

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
    glow             # terminal markdown renderer
  ];

  # Git config
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user.name = "Jamie Pond";
      user.email = "jamiepond259@gmail.com";
      init.defaultBranch = "main";
      core.editor = "nvim";
      credential.helper = "${pkgs.gh}/bin/gh auth git-credential";
      push.autoSetupRemote = true;
      pull.rebase = false;
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

#   # Claude Code
#   programs.claude-code = {
#     enable = true;
#     # settings = { };      # Add settings if needed
#     # mcpServers = { };    # Add MCP servers if needed
#   };

  # Clone bodgolt if not present
  home.activation.cloneBodgolt = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "$HOME/projects/bodgolt" ]; then
      mkdir -p "$HOME/projects"
      ${pkgs.git}/bin/git clone https://github.com/jamierpond/bodgolt.git "$HOME/projects/bodgolt"
    fi
  '';

  # Home-manager state version (don't change after initial setup)
  home.stateVersion = "24.05";
}
