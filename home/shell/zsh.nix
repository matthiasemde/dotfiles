{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
in {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # oh-my-zsh = {
    #   enable = true;
    # };

    shellAliases = {
      hmu = "nix build .#emdem && ./result/bin/home-manager-generation";
    };

    initContent = builtins.readFile ./config.zsh;
  };
}
