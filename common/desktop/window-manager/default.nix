{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./niri.nix
    ./alacritty.nix
    ./vicinae.nix
    ./stylix.nix
    ./quickshell
  ];

  config = lib.mkIf config.dotfiles.desktop.enable {

    home.packages = with pkgs; [
      swaybg
      libsecret
      xwayland-satellite # xwayland support
    ];

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];
      config.common.default = [
        "gnome"
        "gtk"
      ];
    };

    xdg.configFile."autostart/swaybg.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Wallpaper
      Exec=${pkgs.swaybg}/bin/swaybg -m fill -i ${config.dotfiles.desktop.wallpaper}
      X-GNOME-Autostart-enabled=true
    '';

    xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "text/html" = "firefox.desktop";
        "application/pdf" = "firefox.desktop";
        "video/mp4" = "vlc.desktop";
        "video/x-matroska" = "vlc.desktop";
      };
      associations.added = {
        "video/mp4" = "vlc.desktop";
        "video/x-matroska" = "vlc.desktop";
      };
    };

    services.swayidle =
      let
        # lockCmd = "configure this once quickshell is running";
        display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
      in
      {
        enable = true;

        timeouts = [
          # {
          #   timeout = 300;
          #   command = lockCmd;
          # }
          {
            timeout = 600;
            command = display "off";
            resumeCommand = display "on";
          }
          # {
          #   timeout = 1800;
          #   command = "${pkgs.systemd}/bin/systemctl suspend";
          # }
        ];

        events = {
          # "before-sleep" = lockCmd;
          # "lock" = lockCmd;
          "after-resume" = display "on";
        };

        # Pass -w so swayidle waits for command to finish
        extraArgs = [ "-w" ];
      };
  };
}
