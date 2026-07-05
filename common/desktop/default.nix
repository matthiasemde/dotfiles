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
  ];

  config = lib.mkIf config.dotfiles.desktop.enable {

    fonts.fontconfig.enable = true;

    # Desktop-only programs
    programs.firefox.enable = true;
    programs.firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";

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
