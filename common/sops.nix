{
  config,
  pkgs,
  lib,
  ...
}:
{
  sops.age.keyFile = "${config.home.homeDirectory}/.age-key.txt";
}
