{
  config,
  pkgs,
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
    figlet # fancy strings
    fortune
    lolcat
    screen
    sops
    inetutils

    # simplified man pages
    tldr

    # Development tools
    lazygit
    github-copilot-cli

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

  systemd.user.services.nix-gc = {
    Unit.Description = "Nix garbage collection for user ${config.home.username} (Service)";
    Service = {
      Type = "oneshot";
      ExecStart = "/nix/var/nix/profiles/default/bin/nix-collect-garbage --delete-older-than 7d";
    };
  };

  systemd.user.timers.nix-gc = {
    Unit.Description = "Nix garbage collection for user ${config.home.username} (Timer)";
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  programs.worktrunk = {
    enable = true;
    package = pkgs.worktrunk;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  # Enable essential programs
  programs.zoxide.enable = true;
  programs.fzf.enable = true;

  programs.eza = {
    enable = true;
    icons = "auto";
    colors = "auto";
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
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
      clients = [
        {
          type = "openai-compatible";
          name = "ollama";
          api_base = "http://10.66.8.3:11434/v1";
          models = [
            { name = "gemma4:latest"; }
            { name = "gemma4:26b"; }
            { name = "qwen3.6:latest"; }
            { name = "mistral:7b"; }
            { name = "phi4:14b"; }
          ];
        }
      ];
    };
  };
}
