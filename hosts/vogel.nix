{
  config,
  pkgs,
  lib,
  ...
}:

{
  dotfiles.hostname = "vogel";
  dotfiles.desktop = true;

  # launcher for minecraft
  programs.prismlauncher.enable = true;

  home.packages = with pkgs; [
    android-studio
    discord
    puddletag
  ];
}
