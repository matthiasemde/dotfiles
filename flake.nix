{
  description = "Personal dotfiles for matthias & emdem (with per-host overrides)";

  inputs = {
    # home-manager must follow nixpkgs:
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    homeConfigurations = {
      # ─────────────────────────────────────────────────────────────────────
      #  matthias’s Home Manager configuration
      # ─────────────────────────────────────────────────────────────────────
      matthias = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home/common.nix
          ./home/matthias.nix
        ];

        extraSpecialArgs = {
          username = "matthias";
          email = "matthias@emdemail.de";
          homeDirectory = "/home/matthias";
        };
      };

      # ─────────────────────────────────────────────────────────────────────
      #  emdem’s Home Manager configuration
      # ─────────────────────────────────────────────────────────────────────
      emdem = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home/common.nix
          ./home/emdem.nix
        ];

        extraSpecialArgs = {
          username = "emdem";
          email = "matthias.emde@mvtec.com";
          homeDirectory = "/home/emdem";
        };
      };
    };
  };
}
