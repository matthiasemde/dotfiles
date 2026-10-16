{ ... }:
{
  flake.modules.homeManager.personal =
    {
      config,
      pkgs,
      lib,
      ...
    }:

    {
      dotfiles.atuin.ai = {
        enable = true;
        server = lib.mkDefault "https://atuin-ai.emdecloud.de";
      };
    };
}
