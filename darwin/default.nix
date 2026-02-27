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

  # Platform is set in flake.nix (supports both aarch64-darwin and x86_64-darwin)

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
      autohide-delay = 0.0; # No delay before dock shows
      autohide-time-modifier = 0.0; # No dock show/hide animation
      launchanim = false; # No launch bounce
      mineffect = "scale"; # Fastest minimize effect
      expose-animation-duration = 0.1; # Near-instant Mission Control
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
      "com.apple.sound.beep.feedback" = 0; # Disable UI sound effects
      # Kill animations
      NSAutomaticWindowAnimationsEnabled = false; # No window open/close animations
      NSScrollAnimationEnabled = false; # No smooth scrolling
      NSWindowResizeTime = 0.001; # Instant window resize
    };

    universalaccess = {
      reduceMotion = true; # System-wide reduce motion
      reduceTransparency = true; # Less compositing overhead
    };

    # Defaults not covered by typed nix-darwin options
    CustomUserPreferences = {
      NSGlobalDomain = {
        NSToolbarTitleViewRolloverDelay = 0.0;
        "com.apple.springing.delay" = 0.0;
        NSScrollViewRubberbanding = false; # No rubber-band scrolling
        QLPanelAnimationDuration = 0.0; # Instant Quick Look
      };
      "com.apple.finder" = {
        DisableAllAnimations = true;
      };
      "com.apple.dock" = {
        springboard-show-duration = 0.0;
        springboard-hide-duration = 0.0;
        springboard-page-duration = 0.0;
      };
    };
  };

  # Power management
  # nix-darwin's power.sleep.* sets values globally (both AC and battery).
  # We need AC-specific settings so servers stay alive when plugged in,
  # but the laptop still sleeps normally on battery. pmset -c / -b is
  # the only way to express that distinction.
  system.activationScripts.power.text = ''
    # AC power: never sleep (servers stay alive), display off after 10min
    pmset -c sleep 0 displaysleep 10

    # Battery: sleep after 1min, display off after 2min (preserve battery)
    pmset -b sleep 1 displaysleep 2
  '';

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

  # Tailscale — mesh VPN for SSH access from anywhere
  services.tailscale.enable = true;

  # Required for nix-darwin
  system.stateVersion = 6;
}
