{ config, pkgs, lib, ... }:

{
  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Packages to install
  home.packages = with pkgs; [
    # CLI essentials
    ripgrep
    fd
    fzf
    jq
    tree
    htop
    btop

    # Dev tools
    git
    gh
    lazygit
    neovim
    tmux

    # Languages (replaces nvm/pyenv)
    nodejs_20
    python312
    go

    # Build tools
    yarn
    gnumake
    cmake
    gcc
    bazel

    # Nice to have
    bat
    eza
    delta
    zoxide
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
      # Add aliases here as you migrate them
      # Or keep them in zshrc for now
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

  # Starship prompt (optional - you have a custom prompt)
  # programs.starship.enable = true;

  # Home-manager state version (don't change after initial setup)
  home.stateVersion = "24.05";
}
