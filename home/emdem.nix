{ config, pkgs, lib, ... }:

{
  # If emdem prefers fish instead of zsh:
  programs.zsh.enable  = false;
  programs.fish.enable = true;

  # emdem’s own overrides:
  home.file.".bash_aliases".text = ''
    alias gs="git status"
    alias ga="git add"
  '';
}
