{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Force ZSH execution via .bash_profile for personal profile
  home.file.".bash_profile".text = lib.mkForce ''
    if [ -z "$ZSH_VERSION" ]; then
      exec zsh
    fi
  '';
}
