{ ... }:
{
  flake.modules.homeManager.base =
    { ... }:
    {
      home.file.".shellenv".source = ./shellenv.sh;
    };
}
