# AGENTS.md - Long-term Memory for Dotfiles Repository

## Repository Overview

This is a **Personal Nix Home Manager Dotfiles Repository** for user `matthias` (and `emdem` - work profile).

**Repository Structure:**
```
dotfiles/
├── flake.nix              # Main Nix flake configuration
├── flake.lock             # Nix flake lock file
├── home/                  # Home Manager configurations
│   ├── common.nix         # Shared configuration for both users
│   ├── matthias.nix       # Personal config overrides
│   ├── emdem.nix          # Work config overrides (minimal)
│   ├── git/               # Git configuration module
│   │   ├── default.nix
│   │   └── git.nix
│   └── shell/             # Shell configuration module
│       ├── default.nix
│       ├── zsh.nix
│       ├── atuin.nix
│       ├── config.zsh
│       ├── aliases.zsh
│       └── .p10k.zsh
├── raw/                   # Raw configuration files
│   └── authorized_keys    # SSH authorized keys
└── README.md              # Installation instructions
```

## Key Technologies & Tools

- **Nix Flakes**: Modern package management and system configuration
- **Home Manager**: User environment management for Nix
- **ZSH**: Primary shell with Powerlevel10k theme
- **Git**: Version control with extensive aliases and configuration
- **Atuin**: Enhanced shell history with Catppuccin theme
- **FZF**: Fuzzy finder with custom integrations

## User Profiles

### 1. `matthias` (Personal)
- **Email**: matthias@emdemail.de
- **Home**: /home/matthias
- **Shell**: ZSH with Powerlevel10k
- **Special**: Forces ZSH execution via .bash_profile

### 2. `emdem` (Work/MVTec)
- **Email**: matthias.emde@mvtec.com
- **Home**: /home/emdem
- **Config**: Minimal overrides, mostly inherits from common.nix

## Core Packages & Tools

**Development Tools:**
- github-copilot-cli
- lazygit, git-absorb
- nixfmt-rfc-style
- VS Code (set as default editor)

**Terminal Utilities:**
- ripgrep, fzf, fd, bat
- tree, htop, ncdu
- nnn (terminal file manager)
- zoxide (smart cd)

**System Tools:**
- bind (nslookup)
- gnupg, pinentry-curses

## Special Configurations

### Shell Features
- **Custom FZF UI Framework**: Generic `fzf_ui()` function for creating interactive prompts
- **Zoxide Integration**: `Ctrl+T Ctrl+T` for directory navigation
- **Git Branch Checkout**: `Ctrl+T Ctrl+B` for interactive branch switching
- **HConfig Build Helper**: `Ctrl+T Ctrl+H` for HALCON build configurations
- **Catppuccin Theme**: Used for FZF and Atuin

### Git Configuration
- **GPG Signing**: Enabled for commits and tags
- **Signing Key**: B553F8169E97D0E33563F977DE0DBC6804FF7C75
- **GitAlias Integration**: External git aliases from GitAlias project
- **Advanced Features**: 
  - Diff algorithm: histogram
  - Merge conflict style: zdiff3
  - Auto-rebase on pull
  - Auto-setup remote on push

### Work-Specific (HALCON/MVTec)
- **HALCON Environment**: Integration with HALCON development tools
- **Benchmark Tools**: Aliases for hbenchop (HALCON benchmarking)
- **Build System**: hconfig, hbuild integration
- **Network Share Sync**: `install_on_network_share()` function
- **License Management**: Aliases for different HALCON license versions

## Installation Commands

```bash
# Personal profile
nix run github:nix-community/home-manager -- switch --flake .#matthias

# Work profile  
nix run github:nix-community/home-manager -- switch --flake .#emdem

# Update flake
nix flake update

# Quick home manager update (alias: hmu)
nix build ~/dotfiles#$USER && ./result/bin/home-manager-generation
```

## Key Aliases & Functions

**Configuration Editing:**
- `brc` - Edit shell config
- `als` - Edit aliases
- `hmu` - Update home manager

**HALCON Development:**
- `hb()` - Build and set environment
- `hbu()`, `hbdlu()` - Build specific targets
- `hu()`, `hdlu()` - Run unit tests with filter
- `sn` - Sync to network share
- Various `hb_*` benchmark functions

**Utilities:**
- `ll` - ls -la
- `c` - clear
- `size` - du -sh
- `mem` - time with memory usage
- `tag` - Generate ctags for HALCON source

## Git Repository State

- **Current Branch**: main
- **Status**: 10 commits ahead of origin/main
- **Stash**: 1 entry (WIP on authorized_keys feature)
- **Recent Work**: Integration of Home Manager without root privileges

## Important Notes

1. **No Root Required**: Repository is designed to work without root privileges
2. **Multi-User Setup**: Supports both personal and work profiles
3. **Modular Design**: Configuration split into logical modules (git, shell, etc.)
4. **Work Integration**: Heavy integration with MVTec/HALCON development workflow
5. **Theme Consistency**: Catppuccin theme used across tools (Atuin, FZF)

## Environment Variables

- `EDITOR` / `VISUAL`: "code --wait" (VS Code)
- `HALCON_SOURCE_DIR`: "${HOME}/halcon/current"
- `FZF_DEFAULT_OPTS`: Catppuccin color scheme
- `HALCON_LICENSE_FILE`: Configurable license paths

## Maintenance

- Regular `nix flake update` to keep packages current
- Git configuration includes auto-updates and pruning
- Home Manager state version: 25.05