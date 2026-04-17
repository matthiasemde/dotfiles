{
  config,
  pkgs,
  homeDirectory,
  ...
}:

let
  catppuccinAtuin = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "atuin";
    rev = "main";
    sha256 = "sha256-4V9Rz37PlBLB1E3JVVYzrJwe9XXlKAFAO5gxWW/cTCw=";
  };
in
{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      db_path = "${homeDirectory}/.history.db";
      invert = true;
      inline_height = 20;
      show_help = false;
      prefers_reduced_motion = true;

      # Make sure Atuin uses the Catppuccin theme
      theme.name = "catppuccin-mocha-sky";
    };
  };

  # Add Catppuccin theme to atuin config
  xdg.configFile."atuin/themes".source = "${catppuccinAtuin}/themes/mocha";
}
