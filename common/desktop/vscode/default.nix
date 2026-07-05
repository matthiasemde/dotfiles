{
  config,
  pkgs,
  lib,
  ...
}:

let
  workbenchDir = "lib/vscode/resources/app/out/vs/code/electron-browser/workbench";

  c = config.lib.stylix.colors.withHashtag;
  background = c.base00;
  surface = c.base01;
  selection = c.base02;

  foreground = c.base05;
  muted = c.base03;

  primary = c.base0D; # blue
  secondary = c.base0E; # magenta
  accent = c.base0C; # cyan

  success = c.base0B;
  warning = c.base0A;
  error = c.base08;

  customCSS = pkgs.replaceVars ./custom.css {
    background = background;
    primary = primary;
    muted = muted;
  };

  settings = pkgs.replaceVars ./settings.json {
    background = background;
    foreground = foreground;
    muted = muted;
    surface = surface;
  };

  vscodePatched = pkgs.vscode.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      workbench="$out/${workbenchDir}"

      # Patch workbench.html to inject custom CSS and JS.
      sed -i \
        -e 's|</head>|<link rel="stylesheet" href="./custom.css">\n\t</head>|' \
        -e 's|</body>|<script src="./custom.js"></script>\n\t</body>|' \
        "$workbench/workbench.html"

      cp ${customCSS} "$workbench/custom.css"
      cp ${./custom.js} "$workbench/custom.js"
    '';
  });
in
{
  config = lib.mkIf config.dotfiles.desktop.enable {
    programs.vscode = {
      enable = true;
      package = vscodePatched;

      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          # s-h-a-d-o-w.vscode-custom-css
          jnoortheen.nix-ide
          catppuccin.catppuccin-vsc
          catppuccin.catppuccin-vsc-icons
          editorconfig.editorconfig
          mhutchie.git-graph
          donjayamanne.githistory
          ms-vscode.hexeditor
          ms-vscode-remote.remote-ssh
          github.copilot
          github.copilot-chat
        ];

        userSettings = builtins.fromJSON (builtins.readFile settings);
        keybindings = builtins.fromJSON (builtins.readFile ./keybindings.json);
      };
    };
  };
}
