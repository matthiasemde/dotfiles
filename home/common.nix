{ config, pkgs, username, email, homeDirectory, ... }:

{
  # ─────────────────────────────────────────────────────────────────────────
  #  Shared settings for every user (bash, a few defaults, host‐specific bits)
  # ─────────────────────────────────────────────────────────────────────────
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion  = "25.05";

  programs.git = {
    enable = true;
    userEmail = email;
    userName = "Matthias Emde";
  };

  # Ensure we always have a decent shell:
  programs.bash.enable = true;
}
