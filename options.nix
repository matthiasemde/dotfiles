{
  lib,
  config,
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
