{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./thunderbird.nix ];

  dotfiles.atuin.ai = {
    enable = true;
    server = lib.mkDefault "https://atuin-ai.emdecloud.de";
  };
}
