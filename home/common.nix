{ config, pkgs, lib, username, email, homeDirectory, ... }:

let
  # Define Catppuccin colors for Starship prompt
  catppuccin = {
    rosewater  = "#F5E0DC";
    flamingo    = "#F2CDCD";
    mauve       = "#CBA6F7";
    pink        = "#F5C2E7";
    maroon      = "#E8A2AF";
    red         = "#F28FAD";
    peach       = "#F8BD96";
    yellow      = "#FAE3B0";
    green       = "#A6E3A1";
    teal        = "#94E2D5";
    sky         = "#89DCEB";
    sapphire    = "#74C7EC";
    blue        = "#89B4FA";
    lavender    = "#B4BEFE";
    text        = "#CAD3F5";
    subtext1    = "#B8C0E0";
    subtext0    = "#A5ADCB";
    overlay2    = "#9399B2";
    overlay1    = "#7F849C";
    overlay0    = "#6C7086";
    surface2    = "#585B70";
    surface1    = "#45475A";
    surface0    = "#313244";
    base        = "#1E1E2E";
    mantle      = "#181825";
    crust       = "#11111B";
  };

in {
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
    fish
    starship
    fzf
    ripgrep
    fd
    bat
    lazygit
    zoxide
    htop
    neofetch
    ncdu
    lolcat
  ];

  #########################
  # Environment Variables #
  #########################
  home.sessionVariables = {
    EDITOR = "code";
    VISUAL = "code";
    # Let fish auto-activate zoxide’s autojump functionality
    _ZO_EVAL = "1";
  };

  ##############################
  # Fish Shell Configuration   #
  ##############################
  programs.fish.enable = true;
  programs.fish.package = pkgs.fish;
  # Use fish with zoxide integration
  programs.fish.shellAliases = {
    ls   = "exa --icons --git";
    ll   = "exa -lah --icons --git";
    c    = "clear";
    p    = "pwd";
  };
  # Define extra fish configuration
  programs.fish.interactiveShellInit = ''
    # ------ Zoxide Integration ------
    # Automatically register directories and enable `z` command
    zoxide init fish | source

    # ------ FZF Keybindings & Settings ------
    set -g -x FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --inline-info'
    # If you have fzf.fish plugin installed via fisher, enable it:
    if test -f (which fzf.fish)
      source (which fzf.fish)
    end

    # ------ FuzzyCD Function (cdf) ------
    function cdf
      # Use fzf to fuzzy-search directories and cd into the selection
      set -l dir (find . -type d 2> /dev/null | fzf --height 40% --reverse --border)
      if test -d "$dir"
        cd "$dir"
      end
    end

    # ------ Prompt: Starship ------
    # Load Starship prompt if available
    if type -q starship
      starship init fish | source
    end

    # ------ Catppuccin Fish Theme ------
    # If you install a Catppuccin Fish theme manually or via Fisher, source it here.
    # For example, assuming you placed catppuccin.fish in ~/.config/fish/functions:
    if test -f ~/.config/fish/functions/catppuccin.fish
      source ~/.config/fish/functions/catppuccin.fish
    end

    # ------ History Fuzzy Search (prefix matching) ------
    # Bind Up/Down arrows to search history for lines starting with the current buffer
    bind \e\[A history-search-backward
    bind \e\[B history-search-forward

    # ------ Fish Auto Suggestions & Syntax Highlighting ------
    # If using fishermen plugins, ensure these exist:
    # fisher install PatrickF1/fzf.fish jorgebucaran/autopair.fish ilancosman/tide@v5
    # Alternatively, install them manually in ~/.config/fish/functions/plugins.fish
  '';

  #############################
  # Starship Prompt Config    #
  #############################
  programs.starship = {
    enable = true;
    # Point to a custom Starship TOML; you can also embed settings inline:
    # You could place this file in ~/.config/starship.toml; Home-Manager can manage it:
    settings = {
      add_newline = false;

      prompt_order = [
        "username"
        "hostname"
        "directory"
        "git_branch"
        "git_status"
        "package"
        "nodejs"
        "docker_context"
        "rust"
        "line_break"
        "battery"
        "time"
      ];

      username = {
        style_user = "bold ${catppuccin.flamingo}";
      };

      hostname = {
        style = "bold ${catppuccin.peach}";
      };

      directory = {
        truncation_length = 3;
        style = "${catppuccin.mauve}";
      };

      git_branch = {
        symbol = " ";
        style = "${catppuccin.peach}";
      };

      git_status = {
        style = "${catppuccin.red}";
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
      };

      prompt = {
        order = [ "time" "character" ];
        prefix = "";
        suffix = " ";
      };

      time = {
        format = "[$time](${catppuccin.sky}) ";
        style = "${catppuccin.sky}";
      };

      character = {
        success_symbol = "[✔](green) ";
        error_symbol = "[✘](red) ";
        vicmd_symbol = "[❮](blue) ";
      };
    };
  };

  ##########################
  # FZF Global Integration #
  ##########################
  programs.fzf.enable = true;

  ########################
  # Zoxide (Autojump)    #
  ########################
  programs.zoxide.enable = true;

  ######################
  # Direnv Integration #
  ######################
  programs.direnv.enable = true;

  #####################
  # Inputrc (Readline)#
  #####################
  # We create a ~/.inputrc file to configure bash/zsh/readline behaviors
  home.file = {
    ".inputrc".text = ''
      # ---------- Case-Insensitive Completion ----------
      set completion-ignore-case on
      set show-all-if-ambiguous on

      # ---------- History Search (Up/Down arrows search by prefix) ----------
      "\e[A": history-search-backward
      "\e[B": history-search-forward

      # ---------- Menu Completion (Tab to complete through options) ----------
      TAB: menu-complete

      # ---------- Make Bash Prompt Colors Show Correctly ----------
      set colored-stats on
      set visible-stats on
    '';
  };

  #################################
  # Git Configuration (Optional)  #
  #################################
  programs.git = {
    enable = true;
    userName = "Matthias Emde";
    userEmail = email;
  };

  ###############
  # Neovim      #
  ###############
  # If you use Neovim, you can enable the Nix-managed NVIM and a Catppuccin theme:
  programs.neovim.enable = true;

  ##################################
  # Bash Configuration (Fallback)  #
  ##################################
  programs.bash.enable = true;

  #######################
  # Environment Hooks   #
  #######################
  # You can drop executable scripts in ~/.config/home-manager/profile.d/
  # to be executed on login; for example, enable neofetch:
  home.file.".config/home-manager/profile.d/neofetch.sh".text = ''
    #!/usr/bin/env bash
    if command -v neofetch >/dev/null 2>&1; then
      neofetch
    fi
  '';
  # Make script executable
  home.activation = {
    neofetchScript = lib.mkBefore ''
      chmod +x ${config.home.homeDirectory}/.config/home-manager/profile.d/neofetch.sh
    '';
  };

  ####################
  # System Services  #
  ####################
  # If you want to enable any user-level services, e.g., a compositor or notification daemon:
  # services.xserver.enable = true;
  # services.xserver.windowManager.i3.enable = true;

  ############################
  # Final Touches & Options #
  ############################
  # You could add more fancy tools: e.g., a modern toplevel shell prompt like "tide" for fish,
  # or integrate with tmux, set up auto-update hooks, etc.
}
