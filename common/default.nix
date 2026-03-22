{
  config,
  pkgs,
  pkgs-small,
  lib,
  username,
  email,
  homeDirectory,
  ...
}:

{
  imports = [
    ./shell
    ./git
    ./security.nix
    ./tools
    ./vscode
  ];

  # User information
  home.username = username;
  home.homeDirectory = homeDirectory;

  # Home Manager state version
  home.stateVersion = "25.05";

  # Home packages
  home.packages = with pkgs; [
    # Nix tools
    nixfmt

    # System utilities
    tree
    htop
    btop
    ncdu
    bind # provides nslookup

    # Terminal utilities
    sl # Choo choo Motherf****r
    ripgrep
    fd
    bat
    fastfetch
    figlet
    lolcat
    screen

    # simplified man pages
    tldr

    # Development tools
    lazygit
    pkgs-small.github-copilot-cli

    # File management
    nnn # terminal file manager

    # Media tools
    imagemagick
  ];

  # Environment variables
  home.sessionVariables = {
    EDITOR = "code --wait";
    VISUAL = "code --wait";
  };

  programs.home-manager.enable = true;

  # Enable essential programs
  programs.zoxide.enable = true;
  programs.fzf.enable = true;

  # GitHub CLI configuration with secure credential storage
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };
}
