{
  config,
  pkgs,
  lib,
  ...
}:

{
  dotfiles.hostname = "vogel";
  dotfiles.desktop.enable = true;
  dotfiles.desktop.wallpaper = "/mnt/mahler/files/Bilder/Wallpapers/SchottlandWallpaper.jpg";

  # launcher for minecraft
  programs.prismlauncher.enable = true;

  programs.niri.settings = {
    outputs = {
      # DELL S2721QS
      "HDMI-A-2" = {
        # Specs
        mode = {
          height = 3840;
          width = 2160;
          refresh = 60.0;
        };
        scale = 1.5;

        # Options
        focus-at-startup = true;
      };

      # DELL U2312HM
      "DP-2" = {
        # Specs
        mode = {
          height = 1920;
          width = 1080;
          refresh = 60.0;
        };
        position = {
          x = -2560;
          y = 100;
        };
        scale = 1.0;
        transform.rotation = 90;

        # Options
        layout = {
          default-column-width.proportion = 1.0;
        };
      };
    };
  };

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
