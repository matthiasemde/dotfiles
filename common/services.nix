{
  config,
  lib,
  pkgs,
  ...
}:
let
  autoUpdate = config.dotfiles.autoUpdate;
in
{
  systemd.user.services.nix-gc = lib.mkIf config.dotfiles.nixGc.enable {
    Unit.Description = "Nix garbage collection for user ${config.home.username} (Service)";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.nix}/bin/nix-collect-garbage --delete-older-than 7d";
    };
  };

  systemd.user.timers.nix-gc = lib.mkIf config.dotfiles.nixGc.enable {
    Unit.Description = "Nix garbage collection for user ${config.home.username} (Timer)";
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.services.home-manager-auto-update = lib.mkIf autoUpdate.enable {
    Unit.Description = "Automatically update Home Manager configuration";
    Service = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.nix}/bin/nix run nixpkgs#home-manager -- switch --flake ${lib.escapeShellArg autoUpdate.flake}
      '';
    };
  };

  systemd.user.timers.home-manager-auto-update = lib.mkIf autoUpdate.enable {
    Unit.Description = "Automatic Home Manager update timer";
    Timer = {
      OnCalendar = autoUpdate.dates;
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
