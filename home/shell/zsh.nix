{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  zoxideConfig = builtins.readFile ./config.zsh;
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

    initContent = builtins.concatStringsSep "\n\n" [
      zoxideConfig
      ''
        # Set Powerlevel10k theme
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

        # zsh plugins
        # source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        # source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      ''
    ];
  };
}
