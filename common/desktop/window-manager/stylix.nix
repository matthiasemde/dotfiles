{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.dotfiles.desktop.enable {
    stylix.enable = true;
    stylix.autoEnable = false;

    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    stylix.polarity = "dark";

    stylix.fonts = {
      monospace = {
        package = pkgs.nerd-fonts.iosevka;
        name = "Iosevka Nerd Font Mono";
      };
      sansSerif = config.stylix.fonts.monospace;
      serif = config.stylix.fonts.monospace;
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };

    stylix.cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    stylix.targets = {
      firefox = {
        enable = true;
        profileNames = [ "matthias" ];
        colorTheme.enable = true;
      };
      vscode.enable = true;
      vicinae.enable = true;
      alacritty.enable = true;
      gtk.enable = true;
      bat.enable = true;
      fzf.enable = true;
      btop.enable = true;
      qt.enable = true;
    };
  };
}
