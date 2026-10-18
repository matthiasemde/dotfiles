{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./mqtt-media-remote.nix
    ./nix-util.nix
  ];
}
