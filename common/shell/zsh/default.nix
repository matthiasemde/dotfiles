{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        source ~/.shellenv
      '')
      ''
        source ${./config.zsh}
        source ${./aliases.zsh}
        # Set Powerlevel10k theme
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      ''
    ];
  };

  home.file.".p10k.zsh".source = ./.p10k.zsh;
}
