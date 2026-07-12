{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./vscode
    ./window-manager
    ./firefox
  ];

  config = lib.mkIf config.dotfiles.desktop.enable {

    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      feishin
      signal-desktop
      element-desktop
      nerd-fonts.iosevka
      keymapp
      vlc
    ];
  };
}
