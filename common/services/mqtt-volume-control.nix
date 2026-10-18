{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.dotfiles.volume-control;
  wireplumberMqttPkg = import ../../packages/mqtt-volume-control { inherit pkgs lib; };
in

{
  options.dotfiles.volume-control = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable WirePlumber MQTT volume control";
    };
    broker = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      description = "MQTT broker address";
    };
    port = lib.mkOption {
      type = lib.types.number;
      default = 1883;
      description = "MQTT broker port";
    };
    user = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "MQTT username (optional)";
    };
    passwordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to file containing MQTT password (optional)";
    };
    topic = lib.mkOption {
      type = lib.types.str;
      default = "wireplumber/volume";
      description = "MQTT topic prefix";
    };
    sink = lib.mkOption {
      type = lib.types.str;
      default = "@DEFAULT_AUDIO_SINK@";
      description = "PipeWire sink to control";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.mqtt-volume-control = {
      Unit = {
        Description = "WirePlumber MQTT Volume Controller";
        After = [
          "pipewire.service"
          "wireplumber.service"
          "sops-nix.service"
        ];
      };

      Service = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "5s";

        Environment = [
          "PATH=${lib.makeBinPath [ pkgs.wireplumber ]}"
          "MQTT_BROKER=${cfg.broker}"
          "MQTT_PORT=${toString cfg.port}"
          "MQTT_TOPIC=${cfg.topic}"
          "SINK=${cfg.sink}"
        ]
        ++ lib.optionals (cfg.user != null && cfg.passwordFile != null) [
          "MQTT_USER=${cfg.user}"
          "MQTT_PASS_FILE=${cfg.passwordFile}"
        ];

        ExecStart = "${wireplumberMqttPkg}/bin/wireplumber-mqtt-volume";
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
