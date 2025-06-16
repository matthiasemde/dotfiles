{ config, pkgs, ... }:

let
  catppuccinAtuin = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "atuin";
    rev = "main";
    sha256 = "sha256-t/Pq+hlCcdSigtk5uzw3n7p5ey0oH/D5S8GO/0wlpKA=";
  };
in {
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      db_path = "/mvtec/home/emdem/.history.db";
      invert = true;
      inline_height = 20;
      show_help = false;
      prefers_reduced_motion = true;
      
      # Make sure Atuin uses the Catppuccin theme
      theme.name = "catppuccin-mocha-sky";
    };
  };

  # Add Catppuccin theme to atuin config
  xdg.configFile."atuin/themes".source =
    "${catppuccinAtuin}/themes/mocha";
}
