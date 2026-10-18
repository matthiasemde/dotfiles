{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.dotfiles.media-remote;
  mediaRemotePkg = import ../../packages/mqtt-media-remote { inherit pkgs lib; };
in

{
  options.dotfiles.media-remote = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable MQTT media remote (volume, playback, sink control)";
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
      default = "media-remote";
      description = "MQTT topic prefix. Commands: <topic>/volume/*, <topic>/playback/*, <topic>/sink/*. Responses: <topic>/state/*";
    };
    sink = lib.mkOption {
      type = lib.types.str;
      default = "@DEFAULT_AUDIO_SINK@";
      description = "PipeWire sink to control for volume commands";
    };
    skipIntroClickX = lib.mkOption {
      type = lib.types.number;
      default = 1750;
      description = "X coordinate to click for 'skip intro' button (for 1920x1080 screens)";
    };
    skipIntroClickY = lib.mkOption {
      type = lib.types.number;
      default = 980;
      description = "Y coordinate to click for 'skip intro' button (for 1920x1080 screens)";
    };
    player = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Specific media player to control (optional, e.g. 'firefox', 'mpv'). Leave empty for default/active player.";
    };
    ydotoolSocket = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "/run/ydotoold/socket";
      description = "Path to ydotool daemon socket. Common paths: /run/ydotoold/socket (system service), /run/user/<UID>/ydotoold/socket (user service). Set to null to use ydotool default.";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.mqtt-media-remote = {
      Unit = {
        Description = "MQTT Media Remote (Volume, Playback, Sink Control)";
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
          "PATH=${
            lib.makeBinPath [
              pkgs.wireplumber
              pkgs.playerctl
              pkgs.ydotool
              pkgs.xdotool
              pkgs.procps
              pkgs.which
            ]
          }"
          "MQTT_BROKER=${cfg.broker}"
          "MQTT_PORT=${toString cfg.port}"
          "MQTT_TOPIC=${cfg.topic}"
          "SINK=${cfg.sink}"
          "SKIP_INTRO_CLICK_X=${toString cfg.skipIntroClickX}"
          "SKIP_INTRO_CLICK_Y=${toString cfg.skipIntroClickY}"
        ]
        ++ lib.optionals (cfg.user != null && cfg.passwordFile != null) [
          "MQTT_USER=${cfg.user}"
          "MQTT_PASS_FILE=${cfg.passwordFile}"
        ]
        ++ lib.optional (cfg.player != null) "PLAYER=${cfg.player}"
        ++ lib.optional (cfg.ydotoolSocket != null) "YDOTOOL_SOCKET=${cfg.ydotoolSocket}";

        ExecStart = "${mediaRemotePkg}/bin/mqtt-media-remote";
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
