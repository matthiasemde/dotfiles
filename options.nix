{
  lib,
  config,
  pkgs,
  ...
}:

with lib;

{
  options.dotfiles = {
    hostname = mkOption {
      type = types.str;
      default = "generic";
      description = "The hostname of the machine being configured.";
    };

    autoUpdate = {
      enable = mkEnableOption "automatic Home Manager updates";

      flake = mkOption {
        type = types.str;
        default = "github:matthiasemde/dotfiles";
        description = "Flake reference used to fetch this Home Manager configuration.";
      };

      dates = mkOption {
        type = types.str;
        default = "04:40";
        description = "Systemd calendar expression for automatic Home Manager updates.";
        example = "daily";
      };
    };

    nixGc.enable = mkEnableOption "periodic Nix garbage collection";

    wine = {
      package = mkOption {
        type = types.package;
        default = pkgs.wineWow64Packages.wayland;
        defaultText = lib.literalExpression "pkgs.wineWow64Packages.wayland";
        description = ''
          The Wine package to use. Defaults to wineWow64Packages.wayland which supports
          both 32-bit and 64-bit Windows applications and prefixes.
        '';
      };
      programs = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              url = mkOption {
                type = types.str;
                description = "Download URL for the Windows installer executable.";
              };
              sha256 = mkOption {
                type = types.str;
                description = "SHA256 hash of the installer executable.";
              };
              installedExe = mkOption {
                type = types.str;
                description = ''
                  Path to the installed binary relative to the Wine prefix C:\ drive.
                  Example: "Program Files/MyApp/myapp.exe"
                '';
              };
              winePrefix = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = ''
                  Wine prefix directory. Defaults to ~/.wine when null.
                  Use an absolute path or a shell expression like "$HOME/.wine/myapp".
                '';
              };
            };
          }
        );
        default = { };
        description = "Windows programs to install and run via Wine, keyed by the command name to expose in PATH.";
        example = lib.literalExpression ''
          {
            myapp = {
              url = "https://example.com/myapp-setup.exe";
              sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
              installedExe = "Program Files/MyApp/myapp.exe";
            };
          }
        '';
      };
    };

    desktop = {
      enable = mkEnableOption "desktop";

      wallpaper = mkOption {
        type = types.str;
        example = "./wallpaper.png";
        description = "Path to the wallpaper image.";
      };
    };

    atuin = {
      syncAddress = mkOption {
        type = types.str;
        default = "https://atuin.emdecloud.de";
        description = "URL of the self-hosted Atuin sync server.";
      };

      ai = {
        enable = mkEnableOption "Atuin AI support";

        model = mkOption {
          type = types.str;
          default = "qwen3.8:27b";
          example = "qwen3.8:27b";
          description = ''
            Ollama model to use for Atuin AI.
            The model (and engine) must support tool calling.
          '';
        };

        server = mkOption {
          type = types.str;
          description = "URL of the machine where atuin-ai-server runs, as seen from Atuin.";
        };
      };
    };
  };
}
