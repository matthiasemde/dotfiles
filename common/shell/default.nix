{ ... }:
{
  imports = [
    ./bash
    ./zsh
    ./atuin.nix
  ];
  home.file.".shellenv".source = ./shellenv.sh;
}
