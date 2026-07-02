{
  config,
  pkgs,
  lib,
  ...
}:

let
  workbenchDir = "lib/vscode/resources/app/out/vs/code/electron-browser/workbench";

  vscodePatched = pkgs.vscode.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      workbench="$out/${workbenchDir}"

      # Patch workbench.html to inject custom CSS and JS.
      sed -i \
        -e 's|</head>|<link rel="stylesheet" href="./custom.css">\n\t</head>|' \
        -e 's|</body>|<script src="./custom.js"></script>\n\t</body>|' \
        "$workbench/workbench.html"

      cp ${./custom.css} "$workbench/custom.css"
      cp ${./custom.js} "$workbench/custom.js"
    '';
  });
in
{
  config = lib.mkIf config.dotfiles.desktop {
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

        userSettings = builtins.fromJSON (builtins.readFile ./settings.json);
        keybindings = builtins.fromJSON (builtins.readFile ./keybindings.json);
      };
    };
  };
}
