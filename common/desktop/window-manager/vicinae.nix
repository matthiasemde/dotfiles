{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.dotfiles.desktop.enable {
    programs.vicinae.enable = true;
    programs.vicinae.systemd.enable = true;
    programs.vicinae.enableFirefoxIntegration = true;
    programs.vicinae.settings = {
      launcher_window = {
        opacity = 1.0;
        compact_mode.enabled = true;
      };
      favorites = [ ];
    };
  };
}
