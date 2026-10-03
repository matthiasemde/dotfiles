{ config, pkgs, lib, ... }:

let
  cfg = config.dotfiles.wine;

  mkWineWrapper =
    name: app:
    let
      installer = pkgs.fetchurl {
        name = "${name}-installer.exe";
        url = app.url;
        sha256 = app.sha256;
      };
      winePrefix = if app.winePrefix != null then app.winePrefix else "$HOME/.wine";
      installedExe = "${winePrefix}/drive_c/${app.installedExe}";
    in
    pkgs.writeShellScriptBin name ''
      set -euo pipefail
      WINE_PREFIX="${winePrefix}"
      INSTALLED="${installedExe}"

      if [ ! -f "$INSTALLED" ]; then
        echo "${name}: not installed yet, running installer..."
        WINEPREFIX="$WINE_PREFIX" ${cfg.package}/bin/wine "${installer}"
        echo "${name}: installation done."
      fi

      export WINEPREFIX="$WINE_PREFIX"
      exec ${cfg.package}/bin/wine "$INSTALLED" "$@"
    '';
in
{
  config = lib.mkIf (cfg.programs != { }) {
    home.packages = [ cfg.package ] ++ (lib.mapAttrsToList mkWineWrapper cfg.programs);
  };
}
