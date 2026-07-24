{
  config,
  pkgs,
  lib,
  niri,
  ...
}:
{
  config = lib.mkIf config.dotfiles.desktop.enable {
    # use niri packages provided by the niri flake
    nixpkgs.overlays = [ niri.overlays.niri ];

    programs.niri.enable = true;
    programs.niri.package = pkgs.niri-unstable;
    home.sessionVariables.NIXOS_OZONE_WL = "1";

    programs.niri.settings = {
      hotkey-overlay.skip-at-startup = true;
      # ask windows to omit client-side-decorations
      prefer-no-csd = true;
      gestures.hot-corners.enable = false;
      layout = {
        gaps = 16;
        center-focused-column = "never";
        always-center-single-column = true;

        default-column-width = {
          proportion = 0.5;
        };

        focus-ring = {
          enable = true;
          width = 2;
        };
      };

      window-rules = [
        # general options
        {
          # make sure the border and focus ring do not draw behind the window
          draw-border-with-background = false;
          geometry-corner-radius = {
            top-left = 8.0;
            top-right = 8.0;
            bottom-left = 8.0;
            bottom-right = 8.0;
          };
          clip-to-geometry = true;
          opacity = 0.75;
          background-effect = {
            blur = true;
          };
        }
        {
          matches = [ { is-active = true; } ];
          opacity = 0.85;
        }
      ];

      binds = {
        # Memo:
        # Prior = PgDown,
        # Next = PgUp
        "Mod+T".action.spawn = "alacritty";
        "Mod+Space".action.spawn = [
          "vicinae"
          "open"
        ];
        "Mod+O".action.toggle-overview = [ ];
        "Mod+L".action.power-off-monitors = [ ];

        "Mod+Left".action.focus-column-left = [ ];
        "Mod+Down".action.focus-window-down = [ ];
        "Mod+Up".action.focus-window-up = [ ];
        "Mod+Right".action.focus-column-right = [ ];

        "Mod+Prior".action.move-column-left = [ ];
        "Mod+Next".action.move-column-right = [ ];

        "Mod+Ctrl+Left".action.focus-monitor-left = [ ];
        "Mod+Ctrl+Right".action.focus-monitor-right = [ ];

        "Mod+Ctrl+Prior".action.move-window-to-monitor-left = [ ];
        "Mod+Ctrl+Next".action.move-window-to-monitor-right = [ ];

        "Mod+R".action.switch-preset-column-width = [ ];
        "Mod+Shift+R".action.switch-preset-column-width-back = [ ];
        "Mod+F".action.maximize-column = [ ];
        "Mod+F12".action.fullscreen-window = [ ];

        "Mod+W".action.close-window = [ ];
        "Mod+D".action.quit = [ ];
      };
    };
  };
}
