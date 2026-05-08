{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.bash = {
    enable = true;
    historyControl = [ "ignoreboth" ];
    historySize = 1000;
    historyFileSize = 2000;
    initExtra = lib.mkMerge [
      # Source common shellenv early  defines utility functions used by everything after
      (lib.mkOrder 500 ''
        source ~/.shellenv
      '')
      # Bash-specific config last - must run after fzf sets its Ctrl+T binding so we can override it
      (lib.mkAfter ''
        source ${./bashrc.sh}
      '')
    ];
  };
}
