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
  };
}
