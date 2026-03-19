{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.dotfiles.desktop {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;

      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          # be5invis.vscode-custom-css
          editorconfig.editorconfig
          mhutchie.git-graph
          donjayamanne.githistory
          ms-vscode.hexeditor
        ];

        userSettings = builtins.fromJSON (builtins.readFile ./settings.json);
      };
    };

    # Custom CSS and JS files
    home.file.".vscode/custom.css".source = ./custom.css;
    home.file.".vscode/custom.js".source = ./custom.js;
  };
}
