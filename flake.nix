{
  description = "Personal dotfiles for matthias & emdem (with per-host overrides)";

  inputs = {
    self.submodules = true;
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

      # Collect host config files from a directory (if it exists)
      hostModulesFrom =
        dir: hostname:
        let
          hostFile = dir + "/${hostname}.nix";
        in
        if builtins.pathExists hostFile then [ hostFile ] else [ ];

      # -------------------------------------------------
      #  mkConfig: build a Home Manager configuration
      #  with optional per-host overrides
      # -------------------------------------------------
      mkConfig =
        {
          username,
          email,
          homeDirectory,
          sshKey,
          gpgSigningKey,
          modules ? [ ],
          hostname ? "generic",
        }:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules =
            [
              ./options.nix
              ./common
            ]
            ++ modules
            ++ hostModulesFrom ./hosts hostname
            ++ hostModulesFrom ./work/hosts hostname
            ++ [
              # Set the hostname option so modules can query it
              { dotfiles.hostname = hostname; }
            ];

          extraSpecialArgs = {
            inherit
              username
              email
              homeDirectory
              sshKey
              gpgSigningKey
              ;
          };
        };

      # -------------------------------------------------
      #  User profiles (shared params for each user)
      # -------------------------------------------------
      users = {
        matthias = {
          username = "matthias";
          email = "matthias@emdemail.de";
          homeDirectory = "/home/matthias";
          sshKey = "DAD59C24B6DD7B5B7CF3BB93619D840AEFD7A8B2";
          gpgSigningKey = "AD15BE5E42AD3039";
          modules = [ ./personal ];
        };

        emdem = {
          username = "emdem";
          email = "matthias.emde@mvtec.com";
          homeDirectory = "/home/emdem";
          sshKey = "72FDB362496827B67F119726D203B96878426456";
          gpgSigningKey = "59517A7B0D783001";
          modules = [ ./work ];
        };
      };

      # -------------------------------------------------
      #  Host assignments: which hosts belong to which user
      #  Add new hosts here as { host = "user"; }
      # -------------------------------------------------
      hosts = {
        bemba = "emdem";
      };

      # Generate user@host configs for all defined hosts
      hostConfigs = builtins.listToAttrs (
        builtins.map (
          hostname:
          let
            username = hosts.${hostname};
            userParams = users.${username};
          in
          {
            name = "${username}@${hostname}";
            value = mkConfig (userParams // { inherit hostname; });
          }
        ) (builtins.attrNames hosts)
      );

      # Generate default (generic) configs for each user
      defaultConfigs = builtins.mapAttrs (_name: params: mkConfig params) users;

    in
    {
      homeConfigurations = defaultConfigs // hostConfigs;

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
          Entrypoint = [ "${pkgs.github-copilot-cli}/bin/copilot" ];
        };
      };
    };
}
