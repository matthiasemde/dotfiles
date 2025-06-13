{ config, pkgs, lib, username, email, homeDirectory, ... }:

{
  imports = [./shell ./git];

  ##############################
  # Home-Manager State Version #
  ##############################
  home.stateVersion  = "25.05";

  ####################
  # User Information #
  ####################
  home.username = username;
  home.homeDirectory = homeDirectory;

  ###################
  # Home Packages   #
  ###################
  home.packages = with pkgs; [
    tree
    ripgrep
    fd
    bat
    lazygit
    htop
    neofetch
    ncdu
    lolcat
    nix
  ];

  programs.zoxide.enable = true;
  programs.fzf.enable = true;

  #############################
  # Starship Prompt Config    #
  #############################
  programs.starship = {
    enable = true;
    # Point to a custom Starship TOML; you can also embed settings inline:
    # You could place this file in ~/.config/starship.toml; Home-Manager can manage it:
    settings = {
      add_newline = false;
    };
  };
}
