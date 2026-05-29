{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf config.dotfiles.desktop {
  fonts.fontconfig.enable = true;

  # Desktop-only programs
  programs.firefox.enable = lib.mkIf config.dotfiles.desktop true;
  programs.firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";

  home.packages = with pkgs; [
    feishin
    signal-desktop
    element-desktop
    nerd-fonts.iosevka
  ];
}
