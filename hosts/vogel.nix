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
    android-tools
    discord
    wineWow64Packages.wayland
    kopia-ui

    # CAD & 3D printing
    prusa-slicer
    freecad

    # Ripping cds
    abcde

    # Ripping dvds
    dvdbackup
    ffmpeg
    makemkv
    handbrake
    lsdvd

    # Ripping videos
    yt-dlp

    # Graphical design
    inkscape

    # PDF tooling
    poppler-utils
  ];
}
