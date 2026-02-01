{ config, pkgs, ... }:

{
  # System-level macOS settings via nix-darwin

  # Declare users (required for home-manager integration)
  users.users.jamiepond = {
    name = "jamiepond";
    home = "/Users/jamiepond";
  };

  # Primary user for user-specific system defaults
  system.primaryUser = "jamiepond";

  # Disable nix-darwin's nix management (using Determinate Nix)
  nix.enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages (available to all users)
  environment.systemPackages = with pkgs; [
    # Add system-wide packages here
  ];

  # macOS system preferences
  system.defaults = {
    dock = {
      autohide = true;
      show-recents = false;
      mru-spaces = false; # Don't rearrange spaces
    };

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXEnableExtensionChangeWarning = false;
    };

    NSGlobalDomain = {
      AppleKeyboardUIMode = 3; # Full keyboard navigation
      ApplePressAndHoldEnabled = false; # Key repeat instead of accents
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
  };

  # Keyboard remapping (alternative to Karabiner for simple mappings)
  # system.keyboard = {
  #   enableKeyMapping = true;
  #   remapCapsLockToEscape = true;
  # };

  # Homebrew integration (for GUI apps not in nixpkgs)
  # homebrew = {
  #   enable = true;
  #   casks = [
  #     "iterm2"
  #     "raycast"
  #   ];
  # };

  # Required for nix-darwin
  system.stateVersion = 4;
}
