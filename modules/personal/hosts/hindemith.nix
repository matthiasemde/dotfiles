{ ... }:
{
  dotfiles.hosts.hindemith.module =
    {
      config,
      pkgs,
      lib,
      ...
    }:

    {
      dotfiles.hostname = "hindemith";
      dotfiles.desktop = true;
    };
}
