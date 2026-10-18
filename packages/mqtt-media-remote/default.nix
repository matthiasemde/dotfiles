{ lib, pkgs, ... }:

let
  pythonWithDeps = pkgs.python3.withPackages (
    ps: with ps; [
      paho-mqtt
      dbus-python
    ]
  );
in

pkgs.writeShellScriptBin "mqtt-media-remote" ''
  exec ${pythonWithDeps}/bin/python3 ${./mqtt-media-remote.py} "$@"
''
