{
  description = "Personal dotfiles for matthias & emdem (with per-host overrides)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      homeConfigurations = {
        # --------------------------------------
        #  matthias's Home Manager configuration
        # --------------------------------------
        matthias = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            ./common
            ./personal
          ];

          extraSpecialArgs = {
            username = "matthias";
            email = "matthias@emdemail.de";
            homeDirectory = "/home/matthias";
            sshKey = "DAD59C24B6DD7B5B7CF3BB93619D840AEFD7A8B2";
            gpgSigningKey = "AD15BE5E42AD3039";
          };
        };

        # --------------------------------------
        #  emdem's Home Manager configuration
        # --------------------------------------
        emdem = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            ./common
            ./work
          ];

          extraSpecialArgs = {
            username = "emdem";
            email = "matthias.emde@mvtec.com";
            homeDirectory = "/home/emdem";
            sshKey = "72FDB362496827B67F119726D203B96878426456";
            gpgSigningKey = "59517A7B0D783001"; # Work GPG key
          };
        };
      };

      packages.x86_64-linux.copilot-image = pkgs.dockerTools.buildLayeredImage {
        name = "nix/copilot-cli";
        tag = "latest";

        contents = [
          pkgs.bashInteractive
          pkgs.coreutils
          pkgs.git
          pkgs.cacert
          pkgs.github-copilot-cli
        ];

        config = {
          Entrypoint = [ "${pkgs.bashInteractive}/bin/bash" ];
        };
      };
    };
}
