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
      "com.apple.sound.beep.volume" = 0.0; # Mute the alert/invalid-action beep entirely
      # Kill animations
      NSAutomaticWindowAnimationsEnabled = false; # No window open/close animations
      NSScrollAnimationEnabled = false; # No smooth scrolling
      NSWindowResizeTime = 0.001; # Instant window resize
    };

    # NOTE: Disabled — writing com.apple.universalaccess is TCC-protected and
    # aborts `darwin-rebuild` activation ("Could not write domain
    # com.apple.universalaccess; exiting") unless the activating terminal has
    # Full Disk Access. To re-enable: grant your terminal Full Disk Access
    # (System Settings > Privacy & Security > Full Disk Access), then uncomment.
    # universalaccess = {
    #   reduceMotion = true; # System-wide reduce motion
    #   reduceTransparency = true; # Less compositing overhead
    # };

    # Defaults not covered by typed nix-darwin options
    CustomUserPreferences = {
      NSGlobalDomain = {
        NSToolbarTitleViewRolloverDelay = 0.0;
        "com.apple.springing.delay" = 0.0;
        NSScrollViewRubberbanding = false; # No rubber-band scrolling
        QLPanelAnimationDuration = 0.0; # Instant Quick Look
        NSAutomaticInlinePredictionEnabled = false; # Grey AI text completion
        WritingToolsEnabled = false;
      };
      "com.apple.finder" = {
        DisableAllAnimations = true;
      };
      "com.apple.dock" = {
        springboard-show-duration = 0.0;
        springboard-hide-duration = 0.0;
        springboard-page-duration = 0.0;
      };
      # Apple Intelligence and Siri off; no re-opt-in after OS updates
      "com.apple.CloudSubscriptionFeatures.optIn" = {
        "1553490127" = false;
        auto_opt_in = false;
      };
      "com.apple.assistant.support" = {
        "Assistant Enabled" = false;
        "Siri Data Sharing Opt-In Status" = 2;
      };
      "com.apple.Siri" = {
        StatusMenuVisible = false;
        VoiceTriggerUserEnabled = false;
      };
      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
        allowIdentifierForAdvertising = false;
        forceLimitAdTracking = true;
      };
      "com.apple.SubmitDiagInfo" = {
        AutoSubmit = false;
        ThirdPartyDataSubmit = false;
      };
      "com.apple.lookup.shared".LookupSuggestionsDisabled = true;
      "com.apple.Spotlight".orderedItems = [
        { enabled = true;  name = "APPLICATIONS"; }
        { enabled = true;  name = "SYSTEM_PREFS"; }
        { enabled = true;  name = "DIRECTORIES"; }
        { enabled = true;  name = "PDF"; }
        { enabled = true;  name = "DOCUMENTS"; }
        { enabled = true;  name = "SOURCE"; }
        { enabled = true;  name = "CONTACT"; }
        { enabled = true;  name = "EVENT_TODO"; }
        { enabled = true;  name = "IMAGES"; }
        { enabled = true;  name = "PRESENTATIONS"; }
        { enabled = true;  name = "SPREADSHEETS"; }
        { enabled = true;  name = "MENU_EXPRESSION"; }
        { enabled = true;  name = "MENU_CONVERSION"; }
        { enabled = true;  name = "MENU_DEFINITION"; }
        { enabled = false; name = "MENU_SPOTLIGHT_SUGGESTIONS"; }
        { enabled = false; name = "MENU_WEBSEARCH"; }
        { enabled = false; name = "MENU_OTHER"; }
        { enabled = false; name = "BOOKMARKS"; }
        { enabled = false; name = "MUSIC"; }
        { enabled = false; name = "MOVIES"; }
        { enabled = false; name = "TIPS"; }
      ];
      # Safari is sandboxed; these only take if the container plist is writable
      "com.apple.Safari" = {
        UniversalSearchEnabled = false;
        SuppressSearchSuggestions = true;
        WebsiteSpecificSearchEnabled = false;
        PreloadTopHit = false;
        ShowFavoritesUnderSmartSearchField = false;
        SendDoNotTrackHTTPHeader = true;
        "WebKitPreferences.privateClickMeasurementEnabled" = false;
      };
      "com.apple.gamed".Disabled = true;
      "com.apple.appstore" = {
        AutoPlayVideoSetting = "off";
        UserSetAutoPlayVideoSetting = true;
        InAppReviewEnabled = false;
      };
      "com.apple.Music".showAppleMusic = false;
      "com.apple.TV".showAppleTVPlus = false;
      "com.apple.photos.shareddefaults" = {
        ShowMemories = false;
        ShowHolidayCalendarEvents = false;
      };
      "com.apple.photoanalysisd".FeaturedContentAllowed = false;
      "com.apple.mail".SuggestionsEnabled = false;
      "com.apple.suggestions".SuggestionsAllowGeocode = false;
      "com.apple.Sharing".ShowSiriSuggestionsInShareSheet = false;
      "com.apple.coreservices.useractivityd" = {
        ActivityAdvertisingAllowed = false;
        ActivityReceivingAllowed = false;
      };
      "com.apple.ncprefs".summarization_enabled = false;
    };
  };

  # Disable Apple daemons that phone home for content/suggestions/ads.
  # Core Spotlight search, iCloud, software updates, auth, and certificate
  # validation are left intact — only the "content" overlay is killed.
  system.activationScripts.disablePhoneHome.text = let
    uid = "$(id -u)";
    agents = [
      "com.apple.ap.promotedcontentd"      # Promoted content / ads
      "com.apple.newsd"                     # Apple News
      "com.apple.tipsd"                     # Tips
      "com.apple.weatherd"                  # Weather widget
      "com.apple.suggestd"                  # Siri Suggestions
      "com.apple.parsecd"                   # Spotlight suggestions backend
      "com.apple.parsec-fbf"               # Parsec feedback
      "com.apple.knowledge-agent"           # Siri knowledge gathering
      "com.apple.knowledgeconstructiond"    # Knowledge graph construction
      "com.apple.siriknowledged"            # Siri knowledge
      "com.apple.spotlightknowledged"       # Spotlight knowledge
      "com.apple.spotlightknowledged.updater"
      "com.apple.spotlightknowledged.importer"
      # Apple Intelligence and Siri
      "com.apple.generativeexperiencesd"
      "com.apple.intelligenceplatformd"
      "com.apple.intelligenceflowd"
      "com.apple.intelligencecontextd"
      "com.apple.intelligencetasksd"
      "com.apple.visualintelligenced"
      "com.apple.siriinferenced"
      "com.apple.siriactionsd"
      "com.apple.Siri.agent"
      "com.apple.assistantd"
      "com.apple.duetexpertd"               # App/action predictions
      "com.apple.naturallanguaged"          # Writing tools / text prediction models
      # Ads, engagement promos, analytics
      "com.apple.ap.adprivacyd"
      "com.apple.amsengagementd"            # App Store / Music promo banners
      "com.apple.feedbackd"
      "com.apple.inputanalyticsd"
      "com.apple.biomesyncd"                # Syncs usage history across devices
      "com.apple.financed"                  # Wallet / Apple Card
      "com.apple.gamed"                     # Game Center
      "com.apple.UsageTrackingAgent"
      "com.apple.ScreenTimeAgent"           # Screen Time stops working
    ];
    disableCmd = agent: ''
      launchctl disable user/${uid}/${agent}
      launchctl bootout gui/${uid}/${agent} 2>/dev/null || true
    '';
    script = builtins.concatStringsSep "\n" (map disableCmd agents);
  in script;

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

  # Homebrew integration (for GUI apps / drivers not available in nixpkgs).
  # Requires Homebrew to be pre-installed (/opt/homebrew). nix-darwin generates
  # a Brewfile and runs `brew bundle` on activation.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "none"; # never uninstall brew packages not listed here
    };
    # NOTE: Homebrew 6+ refuses casks from third-party taps until trusted.
    # One-time per machine (nix-darwin can't do it): brew trust nikitabobko/tap
    taps = [
      "nikitabobko/tap" # AeroSpace
    ];
    brews = [
      "bun"                # JavaScript runtime, bundler & package manager (oven-sh)
      "cmake"              # NOT nix cmake: its 0444 plist templates make bundle Info.plists read-only
    ];
    casks = [
      "aerospace"          # tiling window manager (config: ~/.config/aerospace/aerospace.toml)
      "karabiner-elements" # keyboard customiser (ships a DriverKit system extension — cask-only)
      "font-jetbrains-mono" # JetBrains Mono font
      "1password"          # password manager
      "1password-cli"      # `op` CLI (needed by tamber gen-config; enable in 1Password → Settings → Developer)
      "google-cloud-sdk"   # `gcloud` CLI (tamber build-app / upload-and-publish → GCS). Auth: gcloud auth login
      "visual-studio-code" # VS Code editor
    ];
  };

  # Colima — lightweight Docker runtime (replaces Docker Desktop)
  launchd.user.agents.colima = {
    command = "${pkgs.colima}/bin/colima start --foreground";
    serviceConfig = {
      Label = "com.github.abiosoft.colima";
      RunAtLoad = true;
      KeepAlive = false;       # don't respawn if manually stopped
      StandardOutPath = "/tmp/colima.stdout.log";
      StandardErrorPath = "/tmp/colima.stderr.log";
      EnvironmentVariables = {
        PATH = "${pkgs.lib.makeBinPath [ pkgs.docker pkgs.docker-compose ]}:/usr/bin:/bin:/usr/sbin:/sbin";
        HOME = "/Users/jamiepond";
        XDG_CONFIG_HOME = "/Users/jamiepond/.config";
      };
    };
  };

  # Tailscale — mesh VPN for SSH access from anywhere
  services.tailscale.enable = true;

  # Required for nix-darwin
  system.stateVersion = 6;
}
