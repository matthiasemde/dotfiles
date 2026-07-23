{
  config,
  pkgs,
  lib,
  ...
}:
let
  colors = config.lib.stylix.colors.withHashtag;
in
{
  config = lib.mkIf config.dotfiles.desktop.enable {
    programs.quickshell = {
      enable = true;
      systemd.enable = true;
    };

    # Place all quickshell files at the same level so Theme.js is importable as "./Theme.js"
    xdg.configFile."quickshell/shell.qml".source    = ./qt/shell.qml;
    xdg.configFile."quickshell/Island.qml".source   = ./qt/Island.qml;
    xdg.configFile."quickshell/ClockLayer.qml".source   = ./qt/ClockLayer.qml;
    xdg.configFile."quickshell/PaletteLayer.qml".source = ./qt/PaletteLayer.qml;

    xdg.configFile."quickshell/Theme.js".text = ''
      .pragma library

      var base00 = "${colors.base00}"
      var base01 = "${colors.base01}"
      var base02 = "${colors.base02}"
      var base03 = "${colors.base03}"
      var base04 = "${colors.base04}"
      var base05 = "${colors.base05}"
      var base06 = "${colors.base06}"
      var base07 = "${colors.base07}"

      var base08 = "${colors.base08}"
      var base09 = "${colors.base09}"
      var base0A = "${colors.base0A}"
      var base0B = "${colors.base0B}"
      var base0C = "${colors.base0C}"
      var base0D = "${colors.base0D}"
      var base0E = "${colors.base0E}"
      var base0F = "${colors.base0F}"
    '';
  };
}
