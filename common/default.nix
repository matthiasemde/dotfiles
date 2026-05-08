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
    ./desktop.nix
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

  programs.eza = {
    enable = true;
    icons = "auto";
    colors = "auto";
    extraOptions = [ "--group-directories-first" "--header" ];
  };

  # GitHub CLI configuration with secure credential storage
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  programs.aichat = {
    enable = true;
    settings = {
      model = "ollama:gemma4:latest";

      system_prompt = ''
        You are a command-line assistant.
        Provide only final answers.
        Do not include reasoning, internal thoughts, chain-of-thought, or explanations
        unless explicitly asked.
      '';

      clients = [
        {
          type = "openai-compatible";
          name = "ollama";
          api_base = "http://10.66.8.3:11434/v1";
          models = [
            {
              name = "gemma4:latest";
              supports_function_calling = true;
              supports_vision = false;
            }
            {
              name = "gemma4:26b";
              supports_function_calling = true;
              supports_vision = false;
            }
          ];
        }
      ];
    };
  };
}
