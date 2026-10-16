{ inputs, ... }:
{
  flake.modules.homeManager.base.imports = [
    inputs.niri.homeModules.niri
    inputs.stylix.homeModules.stylix
  ];
}
