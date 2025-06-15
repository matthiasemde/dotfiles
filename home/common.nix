{ config, pkgs, lib, username, email, homeDirectory, ... }:

{
  imports = [./shell ./git];

  # user information
  home.username = username;
  home.homeDirectory = homeDirectory;

  # home packages
  home.packages = with pkgs; [
    neofetch
    nnn # terminal file manager

    # utils
    ripgrep # recursively searches directories for a regex pattern
    fzf # A command-line fuzzy finder

    tree
    ripgrep
    fd
    bat
    lazygit
    htop
    ncdu
    lolcat
    nix
  ];

  programs.zoxide.enable = true;
  programs.fzf.enable = true;

  # environment variables
  home.sessionVariables = {
    EDITOR = "code";
    VISUAL = "code";
  };

  home.file.".bashrc".text = lib.mkForce ''
    # If this is an interactive Bash/sh session, immediately switch to Zsh
    if [ -n "$PS1" ] && [ -z "$ZSH_VERSION" ]; then
      exec zsh -l
    fi
  '';

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";
}
