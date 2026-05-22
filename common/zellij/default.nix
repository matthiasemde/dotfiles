{ pkgs, lib, ... }:
{
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    attachExistingSession = true;
    exitShellOnExit = true;
    settings.defaultShell = "zsh";
    settings.theme = "catppuccin-mocha";
    settings.show_startup_tips = false;
    settings.ui.pane_frames.rounded_corners = true;
  };
}
