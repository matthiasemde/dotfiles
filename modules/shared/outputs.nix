{ inputs, ... }:
{
  systems = [ "x86_64-linux" ];

  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      formatter = pkgs.writeShellApplication {
        name = "treefmt";
        text = ''
          exec ${pkgs.nixfmt-tree}/bin/treefmt --excludes 'work/**' "$@"
        '';
      };

      packages.copilot-image = pkgs.dockerTools.buildLayeredImage {
        name = "nix/copilot-cli";
        tag = "latest";
        contents = [
          pkgs.bashInteractive
          pkgs.coreutils
          pkgs.git
          pkgs.cacert
          pkgs.github-copilot-cli
        ];
        config.Entrypoint = [ "${pkgs.github-copilot-cli}/bin/copilot" ];
      };
    };
}
