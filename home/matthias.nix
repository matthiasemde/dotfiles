{ config, pkgs, lib, ... }:

{
  # If you want a different shell or dotfiles for matthias:
  programs.zsh.enable = true;
  # programs.neovim.enable = true;

  # Any matthias‐specific overrides go here.
  # e.g. if matthias wants a special alias:
  home.file.".bash_aliases".text = ''
    alias ll="ls -lh"
  '';
}
