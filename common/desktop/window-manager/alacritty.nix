{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf config.dotfiles.desktop.enable {
    programs.alacritty.enable = true;
    programs.alacritty.settings = {
      window.decorations = "None";
    };
  };
}
