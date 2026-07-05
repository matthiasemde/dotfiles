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
  };
}
