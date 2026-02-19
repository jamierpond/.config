{
  description = "Jamie's cross-platform Nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # macOS system config (unused on Linux)
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }:
    let
      lib = nixpkgs.lib;

      # Helper to make home-manager config for any system
      mkHome = { system, username, homeDirectory ? null }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./home
            {
              nixpkgs.config.allowUnfree = true;
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
        # Intel Mac Mini running Ubuntu
        "jamie@pondhq-mini" = mkHome {
          system = "x86_64-linux";
          username = "jamie";
        };

        # WSL on Windows
        "jamiepond@wsl" = mkHome {
          system = "x86_64-linux";
          username = "jamiepond";
        };

        # CI/Docker testing
        "jamie@ci" = mkHome {
          system = "x86_64-linux";
          username = "jamie";
        };
      };

      # Dev shells - available on all systems
      # Usage: nix develop .#<shell-name>
      devShells = let
        # Helper to make shells for a given system
        mkShells = system: let
          pkgs = nixpkgs.legacyPackages.${system};
          isLinux = pkgs.stdenv.isLinux;
        in {
          # Default shell with common dev tools
          default = pkgs.mkShell {
            name = "dev";
            packages = with pkgs; [
              git gh lazygit
              ripgrep fd fzf jq
              nodejs_22 pnpm
              python312 uv
              go
              trufflehog
            ];
            shellHook = ''
              echo "Dev shell ready"
            '';
          };

          # C/C++ development
          cpp = pkgs.mkShell {
            name = "cpp-dev";
            packages = with pkgs; [
              gcc clang llvm lld
              cmake ninja gnumake
              pkg-config
              gdb lldb
            ];
            shellHook = ''
              echo "C/C++ dev shell ready"
            '';
          };

          # Audio plugin development (JUCE-friendly)
          audio = pkgs.mkShell {
            name = "audio-dev";
            packages = with pkgs; [
              gcc clang cmake ninja pkg-config
              # Cross-platform audio libs
              libsndfile freetype
            ] ++ lib.optionals isLinux [
              # Linux-specific audio/X11/GTK deps for JUCE
              alsa-lib jack2
              xorg.libX11 xorg.libXext xorg.libXrender
              xorg.libXcursor xorg.libXinerama xorg.libXrandr
              gtk3 webkitgtk
            ];
            shellHook = ''
              echo "Audio dev shell ready (JUCE-compatible)"
            '';
          };
        } // (if isLinux then {
          # Ardour development (Linux only - uses GTK2/X11)
          ardour = pkgs.mkShell {
            name = "ardour-dev";
            nativeBuildInputs = [ pkgs.zsh ];
            packages = with pkgs; [
              python3 pkg-config wafHook
              gtk2 gtkmm2 glib glibmm cairomm pangomm atkmm
              jack2 alsa-lib libsndfile libsamplerate aubio
              rubberband vamp-plugin-sdk fftw fftwFloat
              lv2 lilv serd sord sratom suil
              boost libxml2 libxslt curl liblo taglib
              libusb1 readline libuuid libarchive
              xorg.libX11 xorg.libXext xorg.libXrender
              xorg.libXcursor xorg.libXi xorg.libXinerama
              gcc gnumake
            ];
            shellHook = ''
              echo "Ardour dev environment ready"
              echo "  ./waf configure && ./waf"
            '';
          };
        } else {});
      in {
        x86_64-linux = mkShells "x86_64-linux";
        aarch64-darwin = mkShells "aarch64-darwin";
        x86_64-darwin = mkShells "x86_64-darwin";
      };

      # macOS config (nix-darwin + home-manager integrated)
      darwinConfigurations = let
        mkDarwin = { system, extraModules ? [] }: nix-darwin.lib.darwinSystem {
          modules = [
            ./darwin
            { nixpkgs.hostPlatform = system; }
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.jamiepond = {
                imports = [ ./home ];
                home.username = "jamiepond";
                home.homeDirectory = "/Users/jamiepond";
              };
            }
          ] ++ extraModules;
        };
      in {
        # ARM Mac (Apple Silicon) - daily driver laptop
        "daily-driver" = mkDarwin {
          system = "aarch64-darwin";
          extraModules = [{ networking.hostName = "daily-driver"; }];
        };
        # Intel Mac - headless server in cupboard
        "pondhq-server" = mkDarwin {
          system = "x86_64-darwin";
          extraModules = [
            ./darwin/server.nix
            { networking.hostName = "pondhq-server"; }
          ];
        };
      };
    };
}
