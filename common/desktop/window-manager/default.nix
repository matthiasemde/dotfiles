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
  ];

  config = lib.mkIf config.dotfiles.desktop.enable {

    home.packages = with pkgs; [
      swaybg
      xwayland-satellite # xwayland support
    ];

    xdg.configFile."autostart/swaybg.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Wallpaper
      Exec=${pkgs.swaybg}/bin/swaybg -m fill -i ${config.dotfiles.desktop.wallpaper}
      X-GNOME-Autostart-enabled=true
    '';

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
          {
            timeout = 1800;
            command = "${pkgs.systemd}/bin/systemctl suspend";
          }
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
