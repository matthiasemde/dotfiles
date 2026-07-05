{
  config,
  pkgs,
  lib,
  homeDirectory,
  ...
}:

let
  cfg = config.dotfiles.atuin;
in
{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    settings = {
      db_path = "${homeDirectory}/.history.db";
      sync_address = cfg.syncAddress;
      invert = true;
      inline_height = 20;
      show_help = false;
      prefers_reduced_motion = true;
      secrets_filter = true;
      history_filter = [
        # Exclude assignments and CLI arguments carrying credentials not covered by Atuin's built-in filter.
        "(?i)(password|passwd|secret|token|api[_-]?key|access[_-]?key|private[_-]?key)[A-Za-z0-9_]*[[:space:]]*[:=][[:space:]]*[^[:space:]]+"
        "(?i)--(password|passwd|secret|token|api[_-]?key|access[_-]?key|private[_-]?key)(=|[[:space:]]+)[^[:space:]]+"
        "(?i)https?://[^[:space:]@]+:[^[:space:]@]+@"
        "-----BEGIN[[:space:]]+(RSA[[:space:]]+)?PRIVATE[[:space:]]+KEY-----"
      ];
    }
    # Ai settings: Ollama-backed, proxied through atuin-ai-server
    // lib.optionalAttrs cfg.ai.enable {
      ai = {
        enabled = true;
        endpoint = cfg.ai.server;
        endpoint_protocol = "oss";
        db_path = "${homeDirectory}/.atuin_ai_sessions.db";
        model = cfg.ai.model;
      };
    };
  };

  # Add Catppuccin theme to atuin config
  # xdg.configFile."atuin/themes".source = "${catppuccinAtuin}/themes/mocha";
}
