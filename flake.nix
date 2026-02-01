{
  description = "Jamie's cross-platform Nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # macOS system config (unused on Linux)
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }:
    let
      # Helper to make home-manager config for any system
      mkHome = { system, username, homeDirectory ? null }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./home
            {
              home.username = username;
              home.homeDirectory = if homeDirectory != null
                then homeDirectory
                else if nixpkgs.legacyPackages.${system}.stdenv.isDarwin
                  then "/Users/${username}"
                  else "/home/${username}";
            }
          ];
        };
    in
    {
      # Ubuntu config (standalone home-manager)
      homeConfigurations = {
        "jamie@mm2014" = mkHome {
          system = "x86_64-linux";
          username = "jamie";
        };

        # CI/Docker testing
        "jamie@ci" = mkHome {
          system = "x86_64-linux";
          username = "jamie";
        };

        # Add more Linux hosts here as needed
        # "jamie@other-host" = mkHome { ... };
      };

      # Dev shells for specific projects
      devShells.x86_64-linux = let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in {
        # Ardour development environment
        ardour = pkgs.mkShell {
          name = "ardour-dev";
          packages = with pkgs; [
            # Build system
            python3
            pkg-config
            wafHook

            # Core GTK2 stack (Ardour uses GTK2, not GTK3/4)
            gtk2
            gtkmm2
            glib
            glibmm       # This is 2.4 series in nixpkgs
            cairomm
            pangomm
            atkmm

            # Audio
            jack2
            alsa-lib
            libsndfile
            libsamplerate
            aubio
            rubberband
            vamp-plugin-sdk
            fftw
            fftwFloat

            # LV2/plugin support
            lv2
            lilv
            serd
            sord
            sratom
            suil

            # Other deps
            boost
            libxml2
            libxslt
            curl
            liblo          # OSC
            taglib
            libusb1
            readline
            libuuid
            libarchive

            # X11
            xorg.libX11
            xorg.libXext
            xorg.libXrender
            xorg.libXcursor
            xorg.libXi
            xorg.libXinerama

            # Compiler
            gcc
            gnumake
          ];

          shellHook = ''
            echo "Ardour dev environment ready"
            echo "  ./waf configure && ./waf"
          '';
        };
      };

      # macOS config (nix-darwin + home-manager integrated)
      darwinConfigurations = {
        # Adjust hostname and arch as needed
        "macbook" = darwin.lib.darwinSystem {
          system = "aarch64-darwin"; # Use "x86_64-darwin" for Intel Mac
          modules = [
            ./darwin
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.jamie = import ./home;
            }
          ];
        };
      };
    };
}
