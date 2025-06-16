{ config, pkgs, lib, ... }:

{
  home.file.".bashrc".text = lib.mkForce ''
    # If this is an interactive Bash/sh session, immediately switch to Zsh
    if [ -n "$PS1" ] && [ -z "$ZSH_VERSION" ]; then
      exec zsh -l
    fi
  '';
}
