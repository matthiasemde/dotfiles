{
  description = "Personal dotfiles for matthias & emdem (with per-host overrides)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
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

    matthias = self.homeConfigurations.matthias.activationPackage;
    emdem = self.homeConfigurations.emdem.activationPackage;
    defaultPackage.x86_64-linux = self.matthias;
  };
}
