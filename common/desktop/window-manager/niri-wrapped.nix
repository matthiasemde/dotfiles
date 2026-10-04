{
  niri,
  symlinkJoin,
}:
symlinkJoin {
  pname = "${niri.pname}-wrapped";
  inherit (niri) version;

  # passthru.providedSessions must be preserved so that the wrapped package
  # remains compatible with services.displayManager.sessionPackages. The Niri
  # Home Manager module also uses the Cargo feature metadata to configure
  # screen-casting portals.
  passthru = niri.passthru // {
    unwrapped = niri;
    inherit (niri)
      cargoBuildFeatures
      cargoBuildNoDefaultFeatures
      ;
  };

  paths = [ niri ];

  postBuild = ''
    rm $out/bin/niri-session
    cp -p {${niri},$out}/bin/niri-session
    patch $out/bin/niri-session <${./systemd-no-import-env.patch}
  '';
}
