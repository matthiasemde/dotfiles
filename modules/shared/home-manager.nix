{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.dotfiles;
  mkHome =
    username: hostname: hostModule:
    let
      profile = cfg.profiles.${username};
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit (profile) system;
        config.allowUnfree = true;
      };
      modules = [
        config.flake.modules.homeManager.base
        {
          home.username = username;
          home.homeDirectory = profile.homeDirectory;
          dotfiles = {
            inherit hostname;
            identity = {
              inherit (profile) email gpgSigningKey;
            };
            autoUpdate.flake = lib.mkDefault cfg.flakeRef;
          };
        }
      ]
      ++ profile.modules
      ++ [ hostModule ];
    };
in
{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  options.dotfiles = {
    flakeRef = mkOption {
      type = types.str;
      default = "github:matthiasemde/dotfiles";
      description = "Flake reference used for automatic Home Manager updates.";
    };
    profiles = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            homeDirectory = mkOption { type = types.str; };
            email = mkOption { type = types.str; };
            gpgSigningKey = mkOption { type = types.str; };
            system = mkOption {
              type = types.str;
              default = "x86_64-linux";
            };
            modules = mkOption {
              type = types.listOf types.deferredModule;
              default = [ ];
            };
          };
        }
      );
      default = { };
      description = "Home Manager profiles, keyed by username.";
    };
    hosts = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            profile = mkOption { type = types.str; };
            module = mkOption {
              type = types.deferredModule;
              default = { };
            };
          };
        }
      );
      default = { };
      description = "Host assignments and their Home Manager overrides.";
    };
  };

  config.flake.homeConfigurations =
    lib.mapAttrs (username: _: mkHome username "generic" { }) cfg.profiles
    // lib.mapAttrs' (
      hostname: host:
      lib.nameValuePair "${host.profile}@${hostname}" (mkHome host.profile hostname host.module)
    ) cfg.hosts;
}
